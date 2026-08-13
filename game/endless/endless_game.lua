local BoardView  = require("game.view.board_view.board_view")
local Board      = require("game.shikaku.board")
local Input      = require("game.shikaku.input")
local Selection  = require("game.shikaku.selection")
local Generator  = require("game.shikaku.generator")
local Solver     = require("game.shikaku.solver")
local GameCFG    = require("data.config.game_config")
local HintsManager = require("utils.hints_manager")

local EndlessGame = {}
EndlessGame.__index = EndlessGame

local START_SIZE = 5

function EndlessGame.new()
	local self = setmetatable({}, EndlessGame)
	self.score       = 0
	self.grid_size   = START_SIZE
	self.board        = nil
	self.board_view   = nil
	self.selection    = nil
	self.input        = nil
	self.hints        = nil
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
	if self.board_view then
		self.board_view:Clear()
	end

	self.board = self:_generate(self.grid_size)
	if not self.board then
		print("[EndlessGame] Board generation failed")
		return false
	end

	self.selection = Selection.new(self.board)
	self.board_view:Create(self.board)
	self.input = Input.new(self.selection, self.board_view)
	self.hints = HintsManager.new(self.board, self.board_view, self.input)
	return true
end

function EndlessGame:start()
	self.score       = 0
	self.grid_size   = START_SIZE

	if not self.board_view then
		self:init_board_view()
	end

	self:start_round()
end

function EndlessGame:stop()
if self.board_view then
	self.board_view:Clear()
end
end

function EndlessGame:cleanup()
	self:stop()
	self.board_view = nil
	self.board      = nil
	self.selection  = nil
	self.input      = nil
	self.hints      = nil
end

function EndlessGame:restart()
self:stop()
self:start()
end

function EndlessGame:on_input(action_id, action)
if not self.input then return false end

if action_id == hash("touch") or action_id == nil then
	if action.pressed then
		self.input:MousePressed(action.x, action.y)
		return true
	elseif action.released then
		local placed = self.input:MouseReleased(action.x, action.y)
		if placed and self.board and self.board:IsFull() then
			local rects = self.board:GetAllRectangles()
			if Solver.Check(self.board, rects) then
				self:solve_round()
			end
		end
		return true
	else
		self.input:MouseMoved(action.x, action.y)
		return true
	end
end

if action_id == hash("mouse_button_right") and action.pressed then
	self.input:RightClick(action.x, action.y)
	return true
end

return false
end

function EndlessGame:solve_round()
	self.score     = self.score + 1
	self.grid_size = self.grid_size + 1
	self:start_round()
end

function EndlessGame:use_hint()
	if not self.hints then return false, "no_game" end
	local ok, reason = self.hints:ApplyHint()
	if ok then
		if self.board and self.board:IsFull() then
			local rects = self.board:GetAllRectangles()
			if Solver.Check(self.board, rects) then
				self:solve_round()
			end
		end
	else
		print("[EndlessGame] Hint failed:", reason)
	end
	return ok, reason
end

return EndlessGame