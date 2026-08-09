local Input = {}
Input.__index = Input

local COLOR_DEFAULT = vmath.vector4(1, 1, 1, 1)

local function hsv_to_rgb(h, s, v)
	local r, g, b
	local i = math.floor(h * 6)
	local f = h * 6 - i
	local p = v * (1 - s)
	local q = v * (1 - f * s)
	local t = v * (1 - (1 - f) * s)
	i = i % 6
	if i == 0 then r, g, b = v, t, p
	elseif i == 1 then r, g, b = q, v, p
	elseif i == 2 then r, g, b = p, v, t
	elseif i == 3 then r, g, b = p, q, v
	elseif i == 4 then r, g, b = t, p, v
	elseif i == 5 then r, g, b = v, p, q
	end
	return vmath.vector4(r, g, b, 1)
end

function Input.new(selection, board_view)
	local self = setmetatable({}, Input)
	self.selection = selection
	self.board = selection.board 
	self.board_view = board_view
	self.dragging = false
	self.highlighted = {} 
	self.pending_color = nil 
	self.placed_count = 0
	self.used_colors = {}
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

function Input:GenerateColor()
	if #self.used_colors == 0 then
		local color = hsv_to_rgb(math.random(), 0.75, 0.9)
		table.insert(self.used_colors, color)
		return color
	end

	local attempts = 0
	while attempts < 30 do
		local h = math.random()
		local s = 0.65 + math.random() * 0.25
		local v = 0.75 + math.random() * 0.2
		local color = hsv_to_rgb(h, s, v)

		local too_similar = false
		for _, old in ipairs(self.used_colors) do
			local dist = math.abs(color.x - old.x) + math.abs(color.y - old.y) + math.abs(color.z - old.z)
			if dist < 0.5 then
				too_similar = true
				break
			end
		end

		if not too_similar then
			table.insert(self.used_colors, color)
			return color
		end
		attempts = attempts + 1
	end

	local last = self.used_colors[#self.used_colors]
	local h = (math.random() + 0.5) % 1
	local color = hsv_to_rgb(h, 0.8, 0.85)
	table.insert(self.used_colors, color)
	return color
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
	self.pending_color = self:GenerateColor()

	self.selection:Start(cell.x, cell.y)
	self.selection:Update(cell.x, cell.y)

	local rect = self.selection:GetRectangle()
	self:RepaintPreview(rect)
	self.board_view:UpdatePreviewBg(rect, self.pending_color)

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

	local rect = self.selection:GetRectangle()
	self:RepaintPreview(rect)
	self.board_view:UpdatePreviewBg(rect, self.pending_color)
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
	self.board_view:ClearPreviewBg()

	local rectangle = self.selection:GetRectangle()
	if not rectangle then
		for key, pos in pairs(self.highlighted) do
			self.board_view:SetCellColor(pos.x, pos.y, self:GetCellDisplayColor(pos.x, pos.y))
		end
		self.highlighted = {}
		self.selection:Clear()
		return
	end
	
	local numbers_count = 0
	local target_area = nil
	for _, pos in ipairs(rectangle:GetCells()) do
		local cell = self.board:GetCell(pos.x, pos.y)
		if cell and cell:GetNumber() then
			numbers_count = numbers_count + 1
			target_area = cell:GetNumber()
		end
	end

	if numbers_count ~= 1 then
		print("INVALID: must contain exactly 1 number, got", numbers_count)
		for key, pos in pairs(self.highlighted) do
			self.board_view:SetCellColor(pos.x, pos.y, self:GetCellDisplayColor(pos.x, pos.y))
		end
		self.highlighted = {}
		self.selection:Clear()
		return
	end
	
	if rectangle:GetArea() ~= target_area then
		print("INVALID: area", rectangle:GetArea(), "!= number", target_area)
		for key, pos in pairs(self.highlighted) do
			self.board_view:SetCellColor(pos.x, pos.y, self:GetCellDisplayColor(pos.x, pos.y))
		end
		self.highlighted = {}
		self.selection:Clear()
		return
	end
	
	local overlapping = self.board:GetOverlappingRectangles(rectangle)
	local cells_to_repaint = {}

	for old_rectangle in pairs(overlapping) do
		self.board:RemoveRectangle(old_rectangle)
		self.board_view:RemoveRectangleBg(old_rectangle)
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
	self.board_view:CreateRectangleBg(rectangle, rectangle.color)
	print("PLACED", rectangle.x, rectangle.y, rectangle.width, rectangle.height)

	self.highlighted = {}
	self.selection:Clear()
end

function Input:RightClick(x, y)
	if self.dragging then
		self.dragging = false
		self.board_view:ClearPreviewBg()
		for key, pos in pairs(self.highlighted) do
			self.board_view:SetCellColor(pos.x, pos.y, self:GetCellDisplayColor(pos.x, pos.y))
		end
		self.highlighted = {}
		self.selection:Clear()
		print("CANCELLED drag")
		return
	end
	
	local cell = self.board_view:GetCellFromPosition(x, y)
	if not cell then return end

	local board_cell = self.board:GetCell(cell.x, cell.y)
	if not board_cell then return end

	local rect = board_cell:GetRectangle()
	if not rect then return end

	self.board:RemoveRectangle(rect)
	self.board_view:RemoveRectangleBg(rect)

	local cells_to_repaint = {}
	for _, pos in ipairs(rect:GetCells()) do
		table.insert(cells_to_repaint, pos)
	end
	self:RepaintCells(cells_to_repaint)

	print("REMOVED by right click", rect.x, rect.y, rect.width, rect.height)
end

function Input:Reset()
	self.dragging = false
	self.highlighted = {}
	self.pending_color = nil
	self.placed_count = 0
	self.used_colors = {}
	self.board_view:ClearPreviewBg()
	self.selection:Clear()
end

return Input