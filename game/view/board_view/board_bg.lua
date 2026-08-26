local CFG = require("data.config.board_view_config")

local BoardBg = {}
BoardBg.__index = BoardBg

function BoardBg.new(layout, factory_url)
	local self = setmetatable({}, BoardBg)
	self.layout = layout
	self.factory_url = factory_url
	self.id = nil
	self.board_width = 0
	self.board_height = 0
	return self
end

function BoardBg:create(board)
	self:clear()
	if not self.factory_url then return end

	self.board_width  = board.width
	self.board_height = board.height

	local step      = self.layout.effective_step
	local spacing   = self.layout.effective_spacing
	local cell_size = self.layout.effective_cell_size
	local total_w   = board.width  * step - spacing
	local total_h   = board.height * step - spacing
	local padding   = cell_size * CFG.BOARD_BG.padding_ratio
	local panel_w   = total_w + padding * 2
	local panel_h   = total_h + padding * 2
	local base_size = CFG.BOARD_BG.base_size

	local pos = vmath.vector3(self.layout.settings.start_position.x, self.layout.settings.start_position.y, CFG.Z.board_bg)
	self.id = factory.create(self.factory_url, pos)

	if self.id then
		go.set_position(pos, self.id)
		go.set_scale(vmath.vector3(panel_w / base_size, panel_h / base_size, 1), self.id)
	end
end

function BoardBg:reflow()
	if not self.id then return end

	local step      = self.layout.effective_step
	local spacing   = self.layout.effective_spacing
	local cell_size = self.layout.effective_cell_size
	local total_w   = self.board_width  * step - spacing
	local total_h   = self.board_height * step - spacing
	local padding   = cell_size * CFG.BOARD_BG.padding_ratio
	local panel_w   = total_w + padding * 2
	local panel_h   = total_h + padding * 2
	local base_size = CFG.BOARD_BG.base_size

	local pos = vmath.vector3(self.layout.settings.start_position.x, self.layout.settings.start_position.y, CFG.Z.board_bg)
	go.set_position(pos, self.id)
	go.set_scale(vmath.vector3(panel_w / base_size, panel_h / base_size, 1), self.id)
end

function BoardBg:clear()
	if self.id then
		go.delete(self.id)
		self.id = nil
	end
	self.board_width  = 0
	self.board_height = 0
end

return BoardBg