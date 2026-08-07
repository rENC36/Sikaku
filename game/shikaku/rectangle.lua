local Rectangle = {}
Rectangle.__index = Rectangle

function Rectangle.new(x, y, width, height)
	local self = setmetatable({}, Rectangle)
	self.x = x
	self.y = y
	self.width = width
	self.height = height
	return self
end

function Rectangle:GetArea()
	return self.width * self.height
end

function Rectangle:GetCells()
	local cells = {}
	for y = self.y, self.y + self.height - 1 do
		for x = self.x, self.x + self.width - 1 do
			table.insert(cells, { x = x, y = y })
		end
	end
	return cells
end

return Rectangle
