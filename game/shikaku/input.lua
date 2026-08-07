local Input = {}
Input.__index = Input

local COLOR_DEFAULT = vmath.vector4(1, 1, 1, 1)

local PALETTE = {
	vmath.vector4(0.20, 0.80, 0.20, 1), -- зелёный
	vmath.vector4(0.90, 0.30, 0.30, 1), -- красный
	vmath.vector4(0.30, 0.55, 0.95, 1), -- синий
	vmath.vector4(0.95, 0.80, 0.20, 1), -- жёлтый
	vmath.vector4(0.75, 0.35, 0.95, 1), -- фиолетовый
	vmath.vector4(0.25, 0.85, 0.85, 1), -- голубой
	vmath.vector4(0.95, 0.55, 0.15, 1), -- оранжевый
	vmath.vector4(0.95, 0.45, 0.75, 1), -- розовый
}

function Input.new(selection, board_view)
	local self = setmetatable({}, Input)
	self.selection = selection
	self.board = selection.board 
	self.board_view = board_view
	self.dragging = false
	self.highlighted = {} 
	self.pending_color = nil 
	self.placed_count = 0   
	return self
end

function Input:GetCellDisplayColor(x, y)
	local board_cell = self.board:GetCell(x, y)
	if board_cell then
		local rectangle = board_cell:GetRectangle()
		if rectangle and rectangle.color then
			return rectangle.color
		end
	end
	return COLOR_DEFAULT
end

function Input:RepaintPreview(rectangle)
	local new_highlighted = {}

	if rectangle then
		for yy = rectangle.y, rectangle.y + rectangle.height - 1 do
			for xx = rectangle.x, rectangle.x + rectangle.width - 1 do
				local key = xx .. ":" .. yy
				new_highlighted[key] = { x = xx, y = yy }
			end
		end
	end

	for key, pos in pairs(self.highlighted) do
		if not new_highlighted[key] then
			self.board_view:SetCellColor(pos.x, pos.y, self:GetCellDisplayColor(pos.x, pos.y))
		end
	end

	for _, pos in pairs(new_highlighted) do
		self.board_view:SetCellColor(pos.x, pos.y, self.pending_color)
	end

	self.highlighted = new_highlighted
end

function Input:MousePressed(x, y)
	local cell = self.board_view:GetCellFromPosition(x, y)
	if not cell then
		return
	end

	self.dragging = true
	self.pending_color = PALETTE[(self.placed_count % #PALETTE) + 1]

	self.selection:Start(cell.x, cell.y)
	self.selection:Update(cell.x, cell.y)

	self:RepaintPreview(self.selection:GetRectangle())

	print("START", cell.x, cell.y)
end

function Input:MouseMoved(x, y)
	if not self.dragging then
		return
	end

	local cell = self.board_view:GetCellFromPosition(x, y)
	if not cell then
		return
	end

	self.selection:Update(cell.x, cell.y)
	self:RepaintPreview(self.selection:GetRectangle())
end

function Input:RepaintCells(cells)
	for _, pos in ipairs(cells) do
		self.board_view:SetCellColor(pos.x, pos.y, self:GetCellDisplayColor(pos.x, pos.y))
	end
end

function Input:MouseReleased(x, y)
	if not self.dragging then
		return
	end

	self.dragging = false

	local rectangle = self.selection:GetRectangle()
	if rectangle then
		local overlapping = self.board:GetOverlappingRectangles(rectangle)
		local cells_to_repaint = {}
		
		for old_rectangle in pairs(overlapping) do
			self.board:RemoveRectangle(old_rectangle)
			for _, pos in ipairs(old_rectangle:GetCells()) do
				table.insert(cells_to_repaint, pos)
			end
			print("REMOVED", old_rectangle.x, old_rectangle.y, old_rectangle.width, old_rectangle.height)
		end
		
		rectangle.color = self.pending_color
		self.board:Place(rectangle)
		self.placed_count = self.placed_count + 1
		for _, pos in ipairs(rectangle:GetCells()) do
			table.insert(cells_to_repaint, pos)
		end

		self:RepaintCells(cells_to_repaint)
		print("PLACED", rectangle.x, rectangle.y, rectangle.width, rectangle.height)
	end

	self.highlighted = {}
	self.selection:Clear()
end

function Input:Reset()
	self.dragging = false
	self.highlighted = {}
	self.pending_color = nil
	self.placed_count = 0
	self.selection:Clear()
end

return Input
