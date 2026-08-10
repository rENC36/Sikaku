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
	if i == 0 then     r, g, b = v, t, p
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

function Input:GetSelectionInfo(rectangle)
	if not rectangle then
		return { area = 0, numbers_count = 0, target_area = nil, overlapping = false, overlapping_rect = nil, valid = false, reason = "empty" }
	end

	local area = tonumber(rectangle:GetArea()) or 0
	local numbers_count = 0
	local target_area = nil

	for _, pos in ipairs(rectangle:GetCells()) do
		local cell = self.board:GetCell(pos.x, pos.y)
		if cell and cell:GetNumber() then
			numbers_count = numbers_count + 1
			target_area = tonumber(cell:GetNumber())
		end
	end

	local overlapping = false
	local overlapping_rect = nil
	for old_rectangle in pairs(self.board:GetOverlappingRectangles(rectangle)) do
		overlapping = true
		overlapping_rect = old_rectangle
		break
	end

	local valid = numbers_count == 1 and area == target_area and not overlapping
	local reason = "ok"
	if overlapping then
		reason = "overlap"
	elseif numbers_count == 0 then
		reason = "no_number"
	elseif numbers_count > 1 then
		reason = "many_numbers"
	elseif area ~= target_area then
		reason = "area"
	end

	return {
		area = area,
		numbers_count = numbers_count,
		target_area = target_area,
		overlapping = overlapping,
		overlapping_rect = overlapping_rect,
		valid = valid,
		reason = reason
	}
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
		local color = hsv_to_rgb(math.random(), 0.30, 0.95)
		table.insert(self.used_colors, color)
		return color
	end

	for _ = 1, 30 do
		local h = math.random()
		local s = 0.25 + math.random() * 0.25
		local v = 0.88 + math.random() * 0.10
		local color = hsv_to_rgb(h, s, v)

		local too_similar = false
		for _, old in ipairs(self.used_colors) do
			local dist = math.abs(color.x - old.x) + math.abs(color.y - old.y) + math.abs(color.z - old.z)
			if dist < 0.35 then
				too_similar = true
				break
			end
		end

		if not too_similar then
			table.insert(self.used_colors, color)
			return color
		end
	end

	local h = (math.random() + 0.5) % 1
	local color = hsv_to_rgb(h, 0.30, 0.92)
	table.insert(self.used_colors, color)
	return color
end

function Input:RestoreHighlightedCells()
	for _, pos in pairs(self.highlighted) do
		self.board_view:SetCellColor(pos.x, pos.y, self:GetCellDisplayColor(pos.x, pos.y))
	end
	self.highlighted = {}
end

function Input:RepaintPreview(rectangle, info)
	self.highlighted = {}
end

function Input:MousePressed(x, y)
	local cell = self.board_view:GetCellFromPosition(x, y)
	if not cell then return false end

	self.dragging = true
	self.pending_color = self:GenerateColor()

	self.selection:Start(cell.x, cell.y)
	self.selection:Update(cell.x, cell.y)

	local rect = self.selection:GetRectangle()
	local info = self:GetSelectionInfo(rect)

	self:RepaintPreview(rect, info)
	self.board_view:UpdatePreviewBg(rect, self.pending_color, info)

	print("START", cell.x, cell.y)
	return true
end

function Input:MouseMoved(x, y)
	if not self.dragging then return false end

	local cell = self.board_view:GetCellFromPosition(x, y)
	if not cell then return false end

	self.selection:Update(cell.x, cell.y)

	local rect = self.selection:GetRectangle()
	local info = self:GetSelectionInfo(rect)

	self:RepaintPreview(rect, info)
	self.board_view:UpdatePreviewBg(rect, self.pending_color, info)

	return true
end

function Input:RepaintCells(cells)
	for _, pos in ipairs(cells) do
		self.board_view:SetCellColor(pos.x, pos.y, self:GetCellDisplayColor(pos.x, pos.y))
	end
end

function Input:MouseReleased(x, y)
	if not self.dragging then return false end
	self.dragging = false

	local rectangle = self.selection:GetRectangle()
	if not rectangle then
		self.board_view:ClearPreviewBg()
		self:RestoreHighlightedCells()
		self.selection:Clear()
		self.pending_color = nil
		return false
	end

	local info = self:GetSelectionInfo(rectangle)

	if not info.valid then
		if info.reason == "area" then
			print("INVALID: area", info.area, "!= number", info.target_area)
		elseif info.reason == "overlap" then
			print("INVALID: overlaps another rectangle")
			if info.overlapping_rect then
				print("Overlaps with:", info.overlapping_rect.x, info.overlapping_rect.y, info.overlapping_rect.width, info.overlapping_rect.height)
			end
		else
			print("INVALID:", info.reason)
		end

		self.board_view:ClearPreviewBg()
		self:RestoreHighlightedCells()
		self.selection:Clear()
		self.pending_color = nil
		return false
	end
	
	local placed_color = self.pending_color or COLOR_DEFAULT

	self.board_view:ClearPreviewBg()
	self:RestoreHighlightedCells()
	self.selection:Clear()
	self.pending_color = nil

	rectangle.color = placed_color
	self.board:Place(rectangle)
	self.placed_count = self.placed_count + 1

	self.board_view:CreateRectangleBg(rectangle, rectangle.color)

	print("PLACED", rectangle.x, rectangle.y, rectangle.width, rectangle.height)
	return true
end

function Input:RightClick(x, y)
	if self.dragging then
		self.dragging = false
		self.board_view:ClearPreviewBg()
		self:RestoreHighlightedCells()
		self.selection:Clear()
		print("CANCELLED drag")
		return true
	end

	local cell = self.board_view:GetCellFromPosition(x, y)
	if not cell then return false end

	local board_cell = self.board:GetCell(cell.x, cell.y)
	if not board_cell then return false end

	local rect = board_cell:GetRectangle()
	if not rect then return false end

	self.board:RemoveRectangle(rect)
	self.board_view:RemoveRectangleBg(rect)
	self:RepaintCells(rect:GetCells())

	print("REMOVED by right click", rect.x, rect.y, rect.width, rect.height)
	return true
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