local Board = require("game.shikaku.board")
local Rectangle = require("game.shikaku.rectangle")

local Generator = {}

local SIZES = {
	{ 1, 2 }, { 2, 1 }, { 2, 2 }, { 1, 1 },
	{ 1, 3 }, { 3, 1 }, { 2, 3 }, { 3, 2 },
}

function Generator:SetSeed(seed)
	math.randomseed(seed)
	math.random()
	math.random()
	math.random()
end

function Generator:Generate(width, height, seed)
	if seed then
		self:SetSeed(seed)
	else
		self:SetSeed(os.time())
	end

	local board = Board.new(width, height)
	local success = self:GenerateRectangles(board)
	if not success then
		return self:Generate(width, height, nil)
	end

	return board
end

function Generator:GenerateRectangles(board)
	local used = {}
	local rectangles = {}
	local attempts = 0

	while not self:IsFull(board, used) do
		attempts = attempts + 1
		if attempts > 1000 then
			return false
		end

		local x, y = self:GetFreeCell(board, used)
		local rectangle = self:CreateRectangle(board, used, x, y)
		if rectangle then
			table.insert(rectangles, rectangle)
		end
	end

	for _, rectangle in ipairs(rectangles) do
		local area = rectangle.width * rectangle.height
		local cell = board:GetCell(rectangle.x, rectangle.y)
		cell:SetNumber(area)
	end

	return true
end

function Generator:GetFreeCell(board, used)
	while true do
		local x = math.random(1, board.width)
		local y = math.random(1, board.height)
		local key = x .. ":" .. y
		if not used[key] then
			return x, y
		end
	end
end

function Generator:CreateRectangle(board, used, x, y)
	local order = {}
	for i = 1, #SIZES do
		order[i] = i
	end
	for i = #order, 2, -1 do
		local j = math.random(1, i)
		order[i], order[j] = order[j], order[i]
	end

	for _, i in ipairs(order) do
		local size = SIZES[i]
		local width = size[1]
		local height = size[2]

		if self:CanPlace(board, used, x, y, width, height) then
			for yy = y, y + height - 1 do
				for xx = x, x + width - 1 do
					used[xx .. ":" .. yy] = true
				end
			end
			return Rectangle.new(x, y, width, height)
		end
	end

	return nil
end

function Generator:CanPlace(board, used, x, y, width, height)
	if x + width - 1 > board.width then
		return false
	end
	if y + height - 1 > board.height then
		return false
	end

	for yy = y, y + height - 1 do
		for xx = x, x + width - 1 do
			if used[xx .. ":" .. yy] then
				return false
			end
		end
	end

	return true
end

function Generator:IsFull(board, used)
	for y = 1, board.height do
		for x = 1, board.width do
			if not used[x .. ":" .. y] then
				return false
			end
		end
	end
	return true
end

return Generator