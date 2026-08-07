local CellView = {}
CellView.__index = CellView

function CellView.new(node, x, y)
	local self = setmetatable({}, CellView)
	self.node = node
	self.x = x
	self.y = y
	return self
end

function CellView:SetNumber(number)
	local text_node = gui.get_node("number_" .. self.x .. "_" .. self.y)
	if text_node then
		gui.set_text(text_node, tostring(number))
	end
end

function CellView:SetPosition(x, y)
	gui.set_position(self.node, vmath.vector3(x, y, 0))
end

function CellView:SetSelected(state)
	if state then
		gui.set_color(self.node, vmath.vector4(0.5, 0.8, 1, 1))
	else
		gui.set_color(self.node, vmath.vector4(1, 1, 1, 1))
	end
end

return CellView
