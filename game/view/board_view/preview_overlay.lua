local PreviewOverlay = {}
PreviewOverlay.__index = PreviewOverlay

local PREVIEW_FILL_ALPHA = 0.7

local PALETTE = {
	valid   = vmath.vector4(91 / 255, 217 / 255, 139 / 255, 1),
	invalid = vmath.vector4(245 / 255, 95 / 255, 95 / 255, 1),
}

function PreviewOverlay.new(layout, badge_factory_url, overlay_factory_url, badge_base_size)
	local self = setmetatable({}, PreviewOverlay)
	self.layout = layout
	self.badge_factory_url = badge_factory_url
	self.overlay_factory_url = overlay_factory_url
	self.badge_base_size = badge_base_size
	self.preview_bg_id = nil
	self.preview_badge_id = nil
	return self
end

function PreviewOverlay:update(rectangle, color, info)
	if not rectangle then
		self:clear()
		return
	end

	info = info or { area = rectangle:GetArea(), valid = true }
	local cx, cy, outer_w, outer_h = self.layout:get_preview_bounds(rectangle)
	local valid = info.valid ~= false

	local fill_color = valid
	and vmath.vector4(PALETTE.valid.x, PALETTE.valid.y, PALETTE.valid.z, PREVIEW_FILL_ALPHA)
	or  vmath.vector4(PALETTE.invalid.x, PALETTE.invalid.y, PALETTE.invalid.z, PREVIEW_FILL_ALPHA)

	local preview_pos = vmath.vector3(cx, cy, 0.08)

	if not self.preview_bg_id then
		self.preview_bg_id = factory.create(self.overlay_factory_url, preview_pos)
		if self.preview_bg_id then
			go.set_scale(vmath.vector3(1, 1, 1), self.preview_bg_id)
		end
	end

	if self.preview_bg_id then
		go.set_position(preview_pos, self.preview_bg_id)
		go.set_scale(vmath.vector3(1, 1, 1), self.preview_bg_id)
		local sprite_url = msg.url(nil, self.preview_bg_id, "sprite")
		go.set(sprite_url, "size", vmath.vector3(outer_w, outer_h, 1))
		go.set(sprite_url, "tint", fill_color)
	end

	local badge_size = math.max(24, math.min(38, self.layout.effective_cell_size * 0.85))
	local badge_base = self.badge_base_size or self.layout.base_cell_size or 64
	local badge_scale = vmath.vector3(badge_size / badge_base, badge_size / badge_base, 1)
	local badge_pos = vmath.vector3(cx + outer_w / 2, cy + outer_h / 2, 0.3)

	if not self.preview_badge_id then
		self.preview_badge_id = factory.create(self.badge_factory_url, badge_pos)
	end

	if self.preview_badge_id then
		go.set_position(badge_pos, self.preview_badge_id)
		go.set_scale(badge_scale, self.preview_badge_id)

		local badge_label_url = msg.url(nil, self.preview_badge_id, "label")
		local badge_text = tostring(info.area or 0)
		if not valid and (info.reason == "overlap" or info.overlapping) then
			badge_text = "x"
		end
		label.set_text(badge_label_url, badge_text)

		local badge_color = valid
		and vmath.vector4(0.08, 0.95, 0.35, 1)
		or  vmath.vector4(1.0, 0.12, 0.12, 1)

		go.set(msg.url(nil, self.preview_badge_id, "sprite"), "tint", badge_color)
	end
end

function PreviewOverlay:clear()
	if self.preview_bg_id then
		go.delete(self.preview_bg_id)
		self.preview_bg_id = nil
	end
	if self.preview_badge_id then
		go.delete(self.preview_badge_id)
		self.preview_badge_id = nil
	end
end

return PreviewOverlay