local CFG = require("data.config.board_view_config")

local RectangleOverlay = {}
RectangleOverlay.__index = RectangleOverlay

function RectangleOverlay.new(layout, overlay_factory_url)
	local self = setmetatable({}, RectangleOverlay)
	self.layout = layout
	self.overlay_factory_url = overlay_factory_url
	self.bg_map = {}
	return self
end

function RectangleOverlay:create(rectangle, color)
	if not rectangle then return end
	color = color or vmath.vector4(1, 1, 1, 1)

	local cx, cy, outer_w, outer_h = self.layout:get_preview_bounds(rectangle)
	local pos = vmath.vector3(cx, cy, CFG.Z.placed_bg)
	local id = factory.create(self.overlay_factory_url, pos)
	if not id then return end

	go.set_scale(vmath.vector3(1, 1, 1), id)

	local bg_color = vmath.vector4(color.x, color.y, color.z, CFG.PLACED_FILL_ALPHA)
	local sprite_url = msg.url(nil, id, "sprite")

	go.set_position(pos, id)
	go.set(sprite_url, "size", vmath.vector3(outer_w, outer_h, 1))
	go.set(sprite_url, "tint", bg_color)

	self.bg_map[rectangle] = id
end

function RectangleOverlay:reflow()
	for rectangle, id in pairs(self.bg_map) do
		local cx, cy, outer_w, outer_h = self.layout:get_preview_bounds(rectangle)
		local pos = vmath.vector3(cx, cy, CFG.Z.placed_bg)
		go.set_position(pos, id)
		go.set(msg.url(nil, id, "sprite"), "size", vmath.vector3(outer_w, outer_h, 1))
	end
end

function RectangleOverlay:remove(rectangle)
	local id = self.bg_map[rectangle]
	if not id then return end
	self.bg_map[rectangle] = nil
	go.animate(id, "scale", go.PLAYBACK_ONCE_FORWARD, vmath.vector3(0.01, 0.01, 1), go.EASING_INBACK, 0.2, 0, function()
		go.delete(id)
	end)
end

function RectangleOverlay:clear()
	for rect, id in pairs(self.bg_map) do
		go.delete(id)
	end
	self.bg_map = {}
end

return RectangleOverlay