local CellFactory = {}
CellFactory.__index = CellFactory

function CellFactory.new(factory_url, layout)
	local self = setmetatable({}, CellFactory)
	self.factory_url = factory_url
	self.layout = layout
	self.cells = {}
	return self
end

function CellFactory:create(board)
	self:clear()

	for y = 1, board.height do
		self.cells[y] = {}
		for x = 1, board.width do
			local cell_data = board:GetCell(x, y)
			local pos = self.layout:get_cell_screen_pos(x, y)
			local id = factory.create(self.factory_url, pos)

			if not id then
				print("[CellFactory] WARNING: failed to create cell at", x, y)
			else
				self.cells[y][x] = { id = id, x = x, y = y, data = cell_data }
				msg.post(id, "set_data", {
					x = x, y = y,
					number = cell_data and cell_data.number or nil,
				})
			end
		end
	end
end

function CellFactory:clear()
	for y, row in pairs(self.cells) do
		for x, cell in pairs(row) do
			if cell and cell.id then go.delete(cell.id) end
		end
	end
	self.cells = {}
end

function CellFactory:get_cell(x, y)
	if self.cells[y] then return self.cells[y][x] end
	return nil
end

function CellFactory:set_color(x, y, color)
	local cell = self:get_cell(x, y)
	if not cell then return end
	msg.post(cell.id, "set_color", { color = color })
end

return CellFactory