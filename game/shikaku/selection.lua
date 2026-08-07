local Rectangle = require("game.shikaku.rectangle")

local Selection = {}
Selection.__index = Selection

function Selection.new(board)
	local self = setmetatable({}, Selection)
	self.board = board
	self.start = nil
	self.current = nil
	return self
end

function Selection:Start(x, y)
	self.start = { x = x, y = y }
end

function Selection:Update(x, y)
	self.current = { x = x, y = y }
end

function Selection:GetRectangle()
	if not self.start or not self.current then
		return nil
	end

	local x1 = math.min(self.start.x, self.current.x)
	local y1 = math.min(self.start.y, self.current.y)
	local x2 = math.max(self.start.x, self.current.x)
	local y2 = math.max(self.start.y, self.current.y)

	return Rectangle.new(x1, y1, x2 - x1 + 1, y2 - y1 + 1)
end

function Selection:Clear()
	self.start = nil
	self.current = nil
end

return Selection
