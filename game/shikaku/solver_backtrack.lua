local Rectangle = require("game.shikaku.rectangle")

local SolverBacktrack = {}

function SolverBacktrack.Solve(board)
	local numbers = {}
	for y = 1, board.height do
		for x = 1, board.width do
			local cell = board:GetCell(x, y)
			if cell and cell:GetNumber() then
				table.insert(numbers, {x=x, y=y, n=cell:GetNumber()})
			end
		end
	end

	if #numbers == 0 then return nil end

	table.sort(numbers, function(a, b) return a.n > b.n end)

	local used = {}
	local solution = {}

	local function get_candidates(x, y, n)
		local candidates = {}
		for w = 1, board.width do
			for h = 1, board.height do
				if w * h == n then
					for x1 = math.max(1, x - w + 1), math.min(x, board.width - w + 1) do
						for y1 = math.max(1, y - h + 1), math.min(y, board.height - h + 1) do
							local valid = true
							for yy = y1, y1 + h - 1 do
								for xx = x1, x1 + w - 1 do
									if used[xx..":"..yy] then
										valid = false
										break
									end
								end
								if not valid then break end
							end
							if valid then
								table.insert(candidates, Rectangle.new(x1, y1, w, h))
							end
						end
					end
				end
			end
		end
		return candidates
	end

	local function solve(idx)
		if idx > #numbers then
			return true
		end

		local num = numbers[idx]
		local candidates = get_candidates(num.x, num.y, num.n)

		for _, rect in ipairs(candidates) do
			for _, pos in ipairs(rect:GetCells()) do
				used[pos.x..":"..pos.y] = true
			end
			table.insert(solution, rect)

			if solve(idx + 1) then
				return true
			end

			for _, pos in ipairs(rect:GetCells()) do
				used[pos.x..":"..pos.y] = nil
			end
			table.remove(solution)
		end

		return false
	end

	if solve(1) then
		return solution
	end
	return nil
end

return SolverBacktrack