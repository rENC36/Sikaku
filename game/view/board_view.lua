local BoardView = {}
BoardView.__index = BoardView

local BG_PADDING = {
	0.02,  -- max dim = 1 (1x1)
	0.04,  -- max dim = 2
	0.5,  -- max dim = 3
	0.8,  -- max dim = 4
	1,  -- max dim >= 5
}

function BoardView.new(factory_url, settings)
	local self = setmetatable({}, BoardView)
	self.factory_url = factory_url
	self.settings = settings or {}
	self.settings.cell_size = self.settings.cell_size or 64
	self.settings.spacing = self.settings.spacing or 0
	self.settings.start_position = self.settings.start_position or vmath.vector3(0, 0, 0)
	self.cells = {}
	self.board_width = 0
	self.board_height = 0
	self.bg_map = {}
	self.preview_bg_id = nil
	return self
end

function BoardView:Create(board)
	self.board_width = board.width
	self.board_height = board.height

	local cell_size = self.settings.cell_size
	local spacing = self.settings.spacing
	local step = cell_size + spacing

	local total_w = board.width * step - spacing
	local total_h = board.height * step - spacing

	local ww, wh = window.get_size()
	local max_w = ww * 0.85
	local max_h = wh * 0.75

	if total_w > max_w or total_h > max_h then
		local scale = math.min(max_w / total_w, max_h / total_h)
		cell_size = cell_size * scale
		spacing = spacing * scale
		step = cell_size + spacing
		total_w = board.width * step - spacing
		total_h = board.height * step - spacing
	end

	self.effective_cell_size = cell_size
	self.effective_spacing = spacing
	self.effective_step = step

	self.board_start_x = self.settings.start_position.x - total_w / 2
	self.board_start_y = self.settings.start_position.y + total_h / 2

	for y = 1, board.height do
		self.cells[y] = {}
		for x = 1, board.width do
			local cell_data = board:GetCell(x, y)

			local pos_x = self.board_start_x + (x - 1) * step + cell_size / 2
			local pos_y = self.board_start_y - (y - 1) * step - cell_size / 2

			local position = vmath.vector3(pos_x, pos_y, 0)

			local id = factory.create(self.factory_url, position)
			if not id then
				print("[BoardView] WARNING: failed to create cell at", x, y, "- sprite buffer full?")
			else
				self.cells[y][x] = {
					id = id,
					x = x,
					y = y,
					data = cell_data
				}

				msg.post(id, "set_data", {
					x = x,
					y = y,
					number = cell_data and cell_data.number or nil
				})
			end
		end
	end
end

function BoardView:GetCell(x, y)
	if self.cells[y] then
		return self.cells[y][x]
	end
	return nil
end

function BoardView:Clear()
	for y, row in pairs(self.cells) do
		for x, cell in pairs(row) do
			if cell.id then
				go.delete(cell.id)
			end
		end
	end
	self.cells = {}

	for rect, id in pairs(self.bg_map) do
		go.delete(id)
	end
	self.bg_map = {}

	self:ClearPreviewBg()

	self.effective_cell_size = nil
	self.effective_spacing = nil
	self.effective_step = nil
	self.board_start_x = nil
	self.board_start_y = nil
end

function BoardView:SetCellColor(x, y, color)
	local cell = self:GetCell(x, y)
	if not cell then
		return
	end

	msg.post(cell.id, "set_color", { color = color })
end

function BoardView:GetCellFromPosition(px, py)
	if not self.effective_step then
		return nil
	end

	local step = self.effective_step
	local cell_size = self.effective_cell_size
	local spacing = self.effective_spacing

	local total_w = self.board_width * step - spacing
	local total_h = self.board_height * step - spacing

	local start_x = self.board_start_x
	local start_y = self.board_start_y

	local rel_x = px - start_x
	local rel_y = start_y - py

	local x = math.floor(rel_x / step) + 1
	local y = math.floor(rel_y / step) + 1

	if self.board_width > 0 then
		x = math.max(1, math.min(x, self.board_width))
	end
	if self.board_height > 0 then
		y = math.max(1, math.min(y, self.board_height))
	end

	return self:GetCell(x, y)
end

function BoardView:UpdatePreviewBg(rectangle, color)
	if not rectangle then
		self:ClearPreviewBg()
		return
	end

	local step = self.effective_step
	local spacing = self.effective_spacing
	local max_dim = math.max(rectangle.width, rectangle.height)
	local pad_ratio = BG_PADDING[math.min(max_dim, #BG_PADDING)]
	local pad = self.effective_cell_size * pad_ratio

	local w = rectangle.width * step - spacing - pad * 2
	local h = rectangle.height * step - spacing - pad * 2

	local cx = self.board_start_x + (rectangle.x - 1) * step + (w + pad * 2) / 2
	local cy = self.board_start_y - (rectangle.y - 1) * step - (h + pad * 2) / 2

	local base_size = self.settings.cell_size
	local target_scale = vmath.vector3(
	math.max(0.01, w / base_size), 
	math.max(0.01, h / base_size), 
	1
)
	local pos = vmath.vector3(cx, cy, -0.05)

	if not self.preview_bg_id then
		self.preview_bg_id = factory.create(self.factory_url, pos)
		go.set_scale(target_scale, self.preview_bg_id)

		local preview_color = vmath.vector4(color.x, color.y, color.z, 0.25)
		pcall(function()
			sprite.set_constant(msg.url(nil, self.preview_bg_id, "sprite"), hash("tint"), preview_color)
		end)
	else
		go.set_position(pos, self.preview_bg_id)
		go.set_scale(target_scale, self.preview_bg_id)
	end
end

function BoardView:ClearPreviewBg()
	if self.preview_bg_id then
		go.delete(self.preview_bg_id)
		self.preview_bg_id = nil
	end
end

function BoardView:CreateRectangleBg(rectangle, color)
	local step = self.effective_step
	local spacing = self.effective_spacing
	local max_dim = math.max(rectangle.width, rectangle.height)
	local pad_ratio = BG_PADDING[math.min(max_dim, #BG_PADDING)]
	local pad = self.effective_cell_size * pad_ratio

	local w = rectangle.width * step - spacing - pad * 2
	local h = rectangle.height * step - spacing - pad * 2

	local cx = self.board_start_x + (rectangle.x - 1) * step + (w + pad * 2) / 2
	local cy = self.board_start_y - (rectangle.y - 1) * step - (h + pad * 2) / 2

	local pos = vmath.vector3(cx, cy, -0.1)
	local id = factory.create(self.factory_url, pos)

	local base_size = self.settings.cell_size
	local target_scale = vmath.vector3(w / base_size, h / base_size, 1)

	local bg_color = vmath.vector4(color.x, color.y, color.z, 0.35)

	go.set_scale(vmath.vector3(0.01, 0.01, 1), id)

	local ok, err = pcall(function()
		sprite.set_constant(msg.url(nil, id, "sprite"), hash("tint"), bg_color)
	end)
	if not ok then
		print("[BoardView] Warning: could not set tint on bg sprite:", err)
	end

	go.animate(id, "scale", go.PLAYBACK_ONCE_FORWARD, target_scale, go.EASING_OUTBACK, 0.4)

	self.bg_map[rectangle] = id
end

function BoardView:RemoveRectangleBg(rectangle)
	local id = self.bg_map[rectangle]
	if not id then return end

	go.animate(id, "scale", go.PLAYBACK_ONCE_FORWARD, vmath.vector3(0.01, 0.01, 1), go.EASING_INBACK, 0.2, 0, function()
		go.delete(id)
	end)

	self.bg_map[rectangle] = nil
end

return BoardView