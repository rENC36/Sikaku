local Layout = {}
Layout.__index = Layout

function Layout.new(settings)
	local self = setmetatable({}, Layout)

	self.settings = settings or {}

	self.settings.cell_size =
	self.settings.cell_size or 64

	self.settings.spacing =
	self.settings.spacing or 0

	self.settings.start_position =
	self.settings.start_position
	or vmath.vector3(0, 0, 0)

	self.base_cell_size =
	self.settings.base_cell_size or 64

	self:reset()

	return self
end

function Layout:reset()
	self.effective_cell_size = nil
	self.effective_spacing   = nil
	self.effective_step      = nil
	self.board_start_x       = nil
	self.board_start_y       = nil
end

function Layout:compute(board_width, board_height)
	local cell_size = self.settings.cell_size
	local spacing   = self.settings.spacing
	local step      = cell_size + spacing

	local total_w = board_width  * step - spacing
	local total_h = board_height * step - spacing

	local ww, wh = window.get_size()
	local max_w, max_h = ww * 0.85, wh * 0.75

	if total_w > max_w or total_h > max_h then
		local scale = math.min(max_w / total_w, max_h / total_h)
		cell_size = cell_size * scale
		spacing   = spacing   * scale
		step      = cell_size + spacing
		total_w   = board_width  * step - spacing
		total_h   = board_height * step - spacing
	end

	self.effective_cell_size = cell_size
	self.effective_spacing   = spacing
	self.effective_step      = step

	self.board_start_x = self.settings.start_position.x - total_w / 2
	self.board_start_y = self.settings.start_position.y + total_h / 2

	return total_w, total_h
end

function Layout:get_cell_screen_pos(x, y)
	local step = self.effective_step
	local cs   = self.effective_cell_size
	local px   = self.board_start_x + (x - 1) * step + cs / 2
	local py   = self.board_start_y - (y - 1) * step - cs / 2
	return vmath.vector3(px, py, 0)
end

function Layout:get_preview_bounds(rectangle)
	local step    = self.effective_step
	local spacing = self.effective_spacing
	local outer_w = rectangle.width  * step - spacing
	local outer_h = rectangle.height * step - spacing
	local cx      = self.board_start_x + (rectangle.x - 1) * step + outer_w / 2
	local cy      = self.board_start_y - (rectangle.y - 1) * step - outer_h / 2
	return cx, cy, outer_w, outer_h
end

function Layout:get_cell_from_position(px, py, board_width, board_height)
	if not self.effective_step or not self.effective_cell_size then
		return nil
	end

	local start_x   = self.board_start_x
	local start_y   = self.board_start_y
	local step      = self.effective_step
	local spacing   = self.effective_spacing
	local cell_size = self.effective_cell_size

	local total_w = board_width  * step - spacing
	local total_h = board_height * step - spacing

	local rel_x = px - start_x
	local rel_y = start_y - py

	if rel_x < 0 or rel_y < 0 or rel_x >= total_w or rel_y >= total_h then
		return nil
	end

	local x = math.floor(rel_x / step) + 1
	local y = math.floor(rel_y / step) + 1

	if x < 1 or y < 1 or x > board_width or y > board_height then
		return nil
	end

	local cell_left   = start_x + (x - 1) * step
	local cell_right  = cell_left + cell_size
	local cell_top    = start_y - (y - 1) * step
	local cell_bottom = cell_top - cell_size

	if px < cell_left or px > cell_right or py < cell_bottom or py > cell_top then
		return nil
	end

	return x, y
end

return Layout