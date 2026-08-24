local BoardView  = require("game.view.board_view.board_view")
local Board      = require("game.shikaku.board")
local Input      = require("game.shikaku.input")
local Selection  = require("game.shikaku.selection")
local Solver     = require("game.shikaku.solver")
local Levels     = require("game.shikaku.levels")
local PlayerData = require("game.player.player_data")
local GameCFG    = require("data.config.game_config")
local HintsManager = require("utils.hints_manager")

local ClassicGame = {}
ClassicGame.__index = ClassicGame

local CATEGORY_ORDER = { "easy", "medium", "hard" }

local function get_next_category(current)
	for i, cat in ipairs(CATEGORY_ORDER) do
		if cat == current then
			return CATEGORY_ORDER[i + 1] or CATEGORY_ORDER[1]
		end
	end
	return "easy"
end

function ClassicGame.new()
	local self = setmetatable({}, ClassicGame)
	self.board = nil
	self.board_view = nil
	self.selection = nil
	self.input = nil
	self.hints = nil
	self.category = "easy"
	self.level = 1
	return self
end

function ClassicGame:load_level(category, level)
	self.category = category or self.category
	self.level = level or self.level

	if self.board_view then
		self.board_view:Clear()
	end

	local puzzle = Levels.load(self.category)
	if not puzzle then
		print("[ClassicGame] No puzzle for", self.category)
		return false
	end

	self.board = Board.new(puzzle.width, puzzle.height)
	for y = 1, puzzle.height do
		for x = 1, puzzle.width do
			local n = puzzle.data[y][x]
			if n and n ~= 0 then
				local cell = self.board:GetCell(x, y)
				if cell then cell:SetNumber(n) end
			end
		end
	end

	local ww, wh = window.get_size()
	local bv = GameCFG.BOARD_VIEW
	local fac = GameCFG.FACTORIES

	self.board_view = BoardView.new(fac.cell, {
		cell_size      = bv.cell_size,
		spacing        = bv.spacing,
		base_cell_size = bv.base_cell_size,
		label_offset_y = bv.label_offset_y,
		start_position = vmath.vector3(ww / 2, wh / 2, 0)
	}, {
		preview_factory_url  = fac.preview_bg,
		overlay_factory_url  = fac.overlay,
		badge_factory_url    = fac.badge,
		board_bg_factory_url = fac.board_bg
	})

	self.board_view:Create(self.board)
	self.selection = Selection.new(self.board)
	self.input = Input.new(self.selection, self.board_view)
	self.hints = HintsManager.new(self.board, self.board_view, self.input)

	print("[ClassicGame] Loaded", self.category, "level", self.level)
	return true
end

function ClassicGame:on_input(action_id, action)
	if not self.input then return false end

	if action_id == hash("touch") then
		if action.pressed then
			self.input:MousePressed(action.x, action.y)
		elseif action.released then
			local placed = self.input:MouseReleased(action.x, action.y)
			print("[ClassicGame] MouseReleased placed:", tostring(placed))
			if placed then
				local solved = self:check_solved()
				print("[ClassicGame] check_solved returned:", tostring(solved))
				return solved
			end
		else
			self.input:MouseMoved(action.x, action.y)
		end
		return true
	end

	if action_id == hash("mouse_right") and action.pressed then
		self.input:RightClick(action.x, action.y)
		return true
	end

	return false
end

function ClassicGame:check_solved()
	print("[ClassicGame] check_solved called")
	if not self.board or not self.board:IsFull() then
		print("[ClassicGame] board not full")
		return false
	end
	local rectangles = self.board:GetAllRectangles()
	print("[ClassicGame] rectangles count:", #rectangles)
	if not Solver.Check(self.board, rectangles) then
		print("[ClassicGame] WRONG")
		return false
	end

	print("[ClassicGame] SOLVED! Sending level_completed to /main")
	PlayerData.complete_level(self.category, self.level)
	msg.post("/main", "level_completed")

	self.level = self.level + 1

	if self.level > Levels.count(self.category) then
		if self.category == "hard" then
			print("[ClassicGame] ALL LEVELS COMPLETED!")
			PlayerData.set("game_completed", true)
			PlayerData.save()

			msg.post("/main", "open_classic_levels")
			return true
		end

		self.category = get_next_category(self.category)
		self.level = 1
		PlayerData.set("last_category", self.category)
		PlayerData.set("last_page", 1)
		PlayerData.save()
	end

	Levels.set_level(self.category, self.level)
	self:load_level()
	return true
end

function ClassicGame:use_hint()
	if not self.hints then return false, "no_game" end
	local ok, reason = self.hints:ApplyHint()
	if ok then
		self:check_solved()
	else
		print("[ClassicGame] Hint failed:", reason)
	end
	return ok, reason
end

function ClassicGame:cleanup()
	if self.board_view then
		self.board_view:Clear()
	end
	self.board = nil
	self.board_view = nil
	self.selection = nil
	self.input = nil
	self.hints = nil
end

return ClassicGame