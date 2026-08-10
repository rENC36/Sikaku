local CFG = require("data.config.board_view_config")

local PreviewOverlay = {}
PreviewOverlay.__index = PreviewOverlay

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

	local pal = CFG.PALETTE
	local alpha = CFG.PREVIEW_FILL_ALPHA
	local fill_color = valid
	and vmath.vector4(pal.valid.x, pal.valid.y, pal.valid.z, alpha)
	or  vmath.vector4(pal.invalid.x, pal.invalid.y, pal.invalid.z, alpha)

	local preview_pos = vmath.vector3(cx, cy, CFG.Z.preview_bg)

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

	local badge_cfg = CFG.BADGE
	local badge_size = math.max(badge_cfg.min_size, math.min(badge_cfg.max_size, self.layout.effective_cell_size * badge_cfg.size_ratio))
	local badge_base = self.badge_base_size or self.layout.base_cell_size or 64
	local badge_scale = vmath.vector3(badge_size / badge_base, badge_size / badge_base, 1)
	local badge_pos = vmath.vector3(cx + outer_w / 2, cy + outer_h / 2, CFG.Z.badge)

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

		local badge_color = valid and badge_cfg.valid_color or badge_cfg.invalid_color
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