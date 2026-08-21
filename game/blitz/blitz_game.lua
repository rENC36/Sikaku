local BoardView  = require("game.view.board_view.board_view")
local Board      = require("game.shikaku.board")
local Input      = require("game.shikaku.input")
local Selection  = require("game.shikaku.selection")
local Generator  = require("game.shikaku.generator")
local Solver     = require("game.shikaku.solver")
local PlayerData = require("game.player.player_data")
local GameCFG    = require("data.config.game_config")

local BlitzGame = {}
BlitzGame.__index = BlitzGame

local START_TIME  = 60
local TIME_BONUS  = 15
local TIME_CAP    = 60
local SCORE_BONUS = 25
local START_SIZE  = 5

function BlitzGame.new()
	local self = setmetatable({}, BlitzGame)
	self.score       = 0
	self.timer       = START_TIME
	self.grid_size   = START_SIZE
	self.is_game_over = false
	self.board        = nil
	self.board_view   = nil
	self.selection    = nil
	self.input        = nil
	self.timer_handle = nil
	return self
end

function BlitzGame:init_board_view()
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

function BlitzGame:_generate(size)
	for _ = 1, 30 do
		local b = Generator:Generate(size, size)
		if b then return b end
	end
	return nil
end

function BlitzGame:start_round()
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

function BlitzGame:start()
	self.score       = 0
	self.timer       = START_TIME
	self.grid_size   = START_SIZE
	self.is_game_over = false

	if not self.board_view then
		self:init_board_view()
	end

	self:start_round()
end

function BlitzGame:stop()
	if self.timer_handle then
		timer.cancel(self.timer_handle)
		self.timer_handle = nil
	end
	if self.board_view then
		self.board_view:Clear()
	end
end

function BlitzGame:cleanup()
	self:stop()
	self.board_view = nil
	self.board      = nil
	self.selection  = nil
	self.input      = nil
end

function BlitzGame:restart()
	self:stop()
	self:start()
end

function BlitzGame:start_timer(on_tick)
	if self.timer_handle then
		timer.cancel(self.timer_handle)
	end
	self.timer_handle = timer.delay(1, true, function()
		if self.is_game_over then return end
		self.timer = self.timer - 1
		if self.timer <= 0 then
			self.timer = 0
			self:end_game()
		end
		if on_tick then on_tick(self.timer, self.is_game_over) end
	end)
end

function BlitzGame:end_game()
	if self.is_game_over then return end
	self.is_game_over = true
	
	if self.timer_handle then
		timer.cancel(self.timer_handle)
		self.timer_handle = nil
	end
	
	local old_best = PlayerData.get("stats.blitz_best") or 0
	if self.score > old_best then
		PlayerData.set("stats.blitz_best", self.score)
		PlayerData.save()
	end
end

function BlitzGame:on_input(action_id, action)
	if not self.input or self.is_game_over then return false end

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

	if action_id == hash("mouse_right") and action.pressed then
		self.input:RightClick(action.x, action.y)
		return true
	end

	return false
end

function BlitzGame:solve_round()
	self.score     = self.score + SCORE_BONUS
	self.timer     = math.min(TIME_CAP, self.timer + TIME_BONUS)
	if self.score % 5 == 0 and self.grid_size < 10 then
		self.grid_size = self.grid_size + 1
	end
	self:start_round()
end

return BlitzGame