local Layout           = require("game.view.board_view.layout")
local CellFactory      = require("game.view.board_view.cell_factory")
local PreviewOverlay   = require("game.view.board_view.preview_overlay")
local RectangleOverlay = require("game.view.board_view.rectangle_overlay")
local BoardBg          = require("game.view.board_view.board_bg")

local BoardView = {}
BoardView.__index = BoardView

function BoardView.new(factory_url, settings, options)
	options = options or {}
	local self = setmetatable({}, BoardView)

	self.layout = Layout.new(settings)

	local badge_base_size = options.badge_base_size or settings.cell_size or 64
	local overlay_url     = options.overlay_factory_url or options.preview_factory_url or factory_url

	self.cells    = CellFactory.new(factory_url, self.layout)
	self.preview  = PreviewOverlay.new(self.layout, options.badge_factory_url or factory_url, overlay_url, badge_base_size)
	self.overlays = RectangleOverlay.new(self.layout, overlay_url)
	self.bg       = BoardBg.new(self.layout, options.board_bg_factory_url or nil)

	self.board_width  = 0
	self.board_height = 0

	return self
end

function BoardView:Create(board)
	self.board_width  = board.width
	self.board_height = board.height

	self.layout:compute(board.width, board.height)
	self.bg:create(board)
	self.cells:create(board)
end

function BoardView:GetCell(x, y)
	return self.cells:get_cell(x, y)
end

function BoardView:SetCellColor(x, y, color)
	self.cells:set_color(x, y, color)
end

function BoardView:GetCellFromPosition(px, py)
	local x, y = self.layout:get_cell_from_position(px, py, self.board_width, self.board_height)
	if not x then return nil end
	return self.cells:get_cell(x, y)
end

function BoardView:UpdatePreviewBg(rectangle, color, info)
	self.preview:update(rectangle, color, info)
end

function BoardView:ClearPreviewBg()
	self.preview:clear()
end

function BoardView:CreateRectangleBg(rectangle, color)
	self.overlays:create(rectangle, color)
end

function BoardView:RemoveRectangleBg(rectangle)
	self.overlays:remove(rectangle)
end

function BoardView:Clear()
	self.bg:clear()
	self.cells:clear()
	self.overlays:clear()
	self.preview:clear()

	self.layout:reset()

	self.board_width  = 0
	self.board_height = 0
end

return BoardView