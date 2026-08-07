local Cell = {}
Cell.__index = Cell

function Cell.new(x, y)
	local self = setmetatable({}, Cell)
	self.x = x
	self.y = y
	self.number = nil
	self.rectangle_id = nil
	self.selected = false
	return self
end

function Cell:SetNumber(number)
	self.number = number
end

function Cell:GetNumber()
	return self.number
end

function Cell:SetRectangle(id)
	self.rectangle_id = id
end

function Cell:GetRectangle()
	return self.rectangle_id
end

function Cell:IsOccupied()
	return self.rectangle_id ~= nil
end

function Cell:Select()
	self.selected = true
end

function Cell:Deselect()
	self.selected = false
end

function Cell:IsSelected()
	return self.selected
end

return Cell
