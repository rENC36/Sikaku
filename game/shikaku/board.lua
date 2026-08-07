local Cell = require("game.shikaku.cell")

local Board = {}
Board.__index = Board

function Board.new(width, height)
	local self = setmetatable({}, Board)
	self.width = width
	self.height = height
	self.cells = {}

	for y = 1, height do
		self.cells[y] = {}
		for x = 1, width do
			self.cells[y][x] = Cell.new(x, y)
		end
	end

	return self
end

function Board:Place(rectangle)
	for _, pos in ipairs(rectangle:GetCells()) do
		local cell = self:GetCell(pos.x, pos.y)
		cell:SetRectangle(rectangle)
	end
end

function Board:IsFull()
	for y = 1, self.height do
		for x = 1, self.width do
			local cell = self:GetCell(x, y)
			if not cell:IsOccupied() then
				return false
			end
		end
	end
	return true
end

function Board:GetCell(x, y)
	if self.cells[y] then
		return self.cells[y][x]
	end
	return nil
end

function Board:GetOverlappingRectangles(rectangle)
	local found = {}
	for _, pos in ipairs(rectangle:GetCells()) do
		local cell = self:GetCell(pos.x, pos.y)
		if cell then
			local occupying = cell:GetRectangle()
			if occupying then
				found[occupying] = true
			end
		end
	end
	return found
end

function Board:GetAllRectangles()
	local found = {}
	local added = {} 

	for y = 1, self.height do
		for x = 1, self.width do
			local cell = self:GetCell(x, y)
			if cell then
				local rect = cell:GetRectangle()
				if rect and not added[rect] then
					added[rect] = true
					table.insert(found, rect)
				end
			end
		end
	end

	return found
end

function Board:ClearRectangles()
	for y = 1, self.height do
		for x = 1, self.width do
			local cell = self:GetCell(x, y)
			if cell then
				cell:SetRectangle(nil)
			end
		end
	end
end

function Board:RemoveRectangle(rectangle)
	for _, pos in ipairs(rectangle:GetCells()) do
		local cell = self:GetCell(pos.x, pos.y)
		if cell then
			cell:SetRectangle(nil)
		end
	end
end

function Board:CanPlace(rectangle)
	for _, pos in ipairs(rectangle:GetCells()) do
		local cell = self:GetCell(pos.x, pos.y)
		if cell:IsOccupied() then
			return false
		end
	end
	return true
end

function Board:SetCell(x, y, cell)
	self.cells[y][x] = cell
end

return Board
