local PlayerData = require("game.player.player_data")
local SolverBacktrack = require("game.shikaku.solver_backtrack")

local HintsManager = {}
HintsManager.__index = HintsManager

function HintsManager.new(board, board_view, input)
	local self = setmetatable({}, HintsManager)
	self.board = board
	self.board_view = board_view
	self.input = input
	self.solution = nil
	return self
end

function HintsManager.GetBalance()
	return PlayerData.get("hints.balance") or 3
end

function HintsManager.AddHints(amount)
	local current = HintsManager.GetBalance()
	PlayerData.set("hints.balance", current + amount)
	PlayerData.save()
end

function HintsManager.SpendHint()
	local current = HintsManager.GetBalance()
	if current <= 0 then
		return false
	end
	PlayerData.set("hints.balance", current - 1)
	PlayerData.save()
	return true
end

function HintsManager:EnsureSolution()
	if self.solution then return true end
	if not self.board then return false end

	if self.board._solution then
		self.solution = self.board._solution
		return true
	end

	self.solution = SolverBacktrack.Solve(self.board)
	return self.solution ~= nil
end

function HintsManager:ApplyHint()
	if not self:SpendHint() then
		return false, "no_hints"
	end

	if not self:EnsureSolution() then
		HintsManager.AddHints(1)
		return false, "unsolvable"
	end

	local occupied = {}
	for y = 1, self.board.height do
		for x = 1, self.board.width do
			local cell = self.board:GetCell(x, y)
			if cell and cell:IsOccupied() then
				occupied[x..":"..y] = true
			end
		end
	end

	for _, solution_rect in ipairs(self.solution) do
		local cells = solution_rect:GetCells()
		local all_occupied = true

		for _, pos in ipairs(cells) do
			if not occupied[pos.x..":"..pos.y] then
				all_occupied = false
				break
			end
		end

		if not all_occupied then
			local color = self.input:GenerateColor()
			solution_rect.color = color

			-- Находим число внутри прямоугольника (Board:Place требует number)
			local rect_number = nil
			for ry = solution_rect.y, solution_rect.y + solution_rect.height - 1 do
				for rx = solution_rect.x, solution_rect.x + solution_rect.width - 1 do
					local cell = self.board:GetCell(rx, ry)
					if cell and cell.number and cell.number > 0 then
						rect_number = cell.number
						break
					end
				end
				if rect_number then break end
			end

			if not rect_number then
				print("[HintsManager ERROR] No number in rect at", solution_rect.x, solution_rect.y, solution_rect.width, solution_rect.height)
				HintsManager.AddHints(1)
				return false, "no_number"
			end

			solution_rect.number = rect_number

			local ok, err = pcall(function()
				self.board:Place(solution_rect)
			end)
			if not ok then
				print("[HintsManager ERROR] Place failed:", err)
				HintsManager.AddHints(1)
				return false, "place_failed"
			end

			self.input.placed_count = self.input.placed_count + 1
			self.board_view:CreateRectangleBg(solution_rect, color)

			print("[HintsManager] Hint applied:", solution_rect.x, solution_rect.y, solution_rect.width, solution_rect.height, "number:", rect_number)
			return true, "ok"
		end
	end

	HintsManager.AddHints(1)
	return false, "already_solved"
end

return HintsManager