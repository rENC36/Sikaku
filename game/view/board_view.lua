local BoardView = {}
BoardView.__index = BoardView

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
	return self
end

function BoardView:Create(board)
	self.board_width = board.width
	self.board_height = board.height

	local cell_size = self.settings.cell_size
	local spacing = self.settings.spacing

	for y = 1, board.height do
		self.cells[y] = {}
		for x = 1, board.width do
			local cell_data = board:GetCell(x, y)

			local position = vmath.vector3(
				self.settings.start_position.x + (x - 1) * (cell_size + spacing),
				self.settings.start_position.y + (y - 1) * (cell_size + spacing),
				0
			)

			local id = factory.create(self.factory_url, position)

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
end

function BoardView:SetCellColor(x, y, color)
	local cell = self:GetCell(x, y)
	if not cell then
		return
	end

	msg.post(cell.id, "set_color", { color = color })
end

function BoardView:GetCellFromPosition(px, py)
	local size = self.settings.cell_size
	local spacing = self.settings.spacing
	local step = size + spacing
	local half_step = step / 2
	
	local rel_x = (px - self.settings.start_position.x) + half_step
	local rel_y = (py - self.settings.start_position.y) + half_step

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

return BoardView
