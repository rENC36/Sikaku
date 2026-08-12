local BoardView  = require("game.view.board_view.board_view")
local Board      = require("game.shikaku.board")
local Input      = require("game.shikaku.input")
local Selection  = require("game.shikaku.selection")
local Generator  = require("game.shikaku.generator")
local Solver     = require("game.shikaku.solver")
local PlayerData = require("game.player.player_data")
local GameCFG    = require("data.config.game_config")

local EndlessGame = {}
EndlessGame.__index = EndlessGame

function EndlessGame.new()
	local self = setmetatable({}, EndlessGame)
	self.score       = 0
	self.board        = nil
	self.board_view   = nil
	self.selection    = nil
	self.input        = nil
	self.grid_size = 5
	self.cycle_grid_size = 0
	return self
end

function EndlessGame:init_board_view()
	local ww, wh = window.get_size()
	local settings = {
		cell_size      = GameCFG.BOARD_VIEW.cell_size,
		spacing        = GameCFG.BOARD_VIEW.spacing,
		start_position = vmath.vector3(ww / 2, wh / 2, 0),
	}
	self.board_view = BoardView.new(
	GameCFG.FACTORIES.cell,
	settings,
	{
		badge_factory_url    = GameCFG.FACTORIES.badge,
		preview_factory_url  = GameCFG.FACTORIES.preview_bg,
		overlay_factory_url  = GameCFG.FACTORIES.overlay,
		board_bg_factory_url = GameCFG.FACTORIES.board_bg,
	}
)
end

function EndlessGame:_generate(size)
	for _ = 1, 30 do
		local b = Generator:Generate(size, size)
		if b then return b end
	end
	return nil
end

function EndlessGame:start_round()
	self:init_board_view()
	
	if self.board_view then
		self.board_view:Clear()
	end

	self.board = self:_generate(self.grid_size)
	if not self.board then
		print("[BlitzGame] Board generation failed")
		return false
	end

	self.selection = Selection.new(self.board)
	self.board_view:Create(self.board)
	self.input = Input.new(self.selection, self.board_view)
	return true
end

function EndlessGame:load_level()
	self:update_grid_size()
	
	if self.board_view then
		self.board_view:Clear()
	end

	local puzzle = self:_generate(self.grid_size)
	if not puzzle then
		print("[EndlessGame] No puzzle")
		return false
	end
	
	self:start_round()
	self:save_data()
	msg.post("/endless_game", "set_endless_best", { best = PlayerData.get("stats.endless_best") or 0, score_now = self.score or 0})
	return true
end

function EndlessGame:update_grid_size()
	if self.cycle_grid_size >= 3 then
		self.grid_size = self.grid_size + 1
		self.cycle_grid_size = 0
	end
	self.cycle_grid_size = self.cycle_grid_size + 1
end

function EndlessGame:save_data()
	local old_best = PlayerData.get("stats.endless_best") or 0
	if self.score > old_best then
		PlayerData.set("stats.endless_best", self.score)
		PlayerData.save()
	end
end

function EndlessGame:on_input(action_id, action)
	if not self.input then return false end

	if action_id == hash("touch") then
		if action.pressed then
			self.input:MousePressed(action.x, action.y)
		elseif action.released then
			local placed = self.input:MouseReleased(action.x, action.y)
			if placed then
				return self:check_solved()
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

function EndlessGame:check_solved()
	if not self.board or not self.board:IsFull() then return false end
	local rectangles = self.board:GetAllRectangles()
	if Solver.Check(self.board, rectangles) then
		print("[EndlessGame] SOLVED!")
		self.score = self.score + 1
		self:load_level()
		return true
	else
		print("[EndlessGame] WRONG")
		return false
	end
end

return EndlessGame