local M = {}

local function to_vec(v)
	if v == nil then return nil end
	if type(v) == "userdata" then return v end
	if type(v) == "table" then
		if v.w then return vmath.vector4(v.x, v.y, v.z, v.w) end
		if #v == 4 then return vmath.vector4(v[1], v[2], v[3], v[4]) end
		return vmath.vector3(v[1], v[2], v[3])
	end
	return v
end

function M.apply(node, preset)
	if not preset then return end
	if preset.position then gui.set_position(node, to_vec(preset.position)) end
	if preset.rotation then gui.set_rotation(node, to_vec(preset.rotation)) end
	if preset.scale     then gui.set_scale(node,     to_vec(preset.scale)) end
	if preset.color     then gui.set_color(node,     to_vec(preset.color)) end
	if preset.size      then gui.set_size(node,      to_vec(preset.size)) end
end

function M.animate(node, preset, callback)
	preset = preset or {}
	local duration = preset.duration or 0.3
	local easing   = preset.easing   or gui.EASING_OUTQUAD
	local delay    = preset.delay    or 0

	if preset.cancel then
		gui.cancel_animation(node, hash("position"))
		gui.cancel_animation(node, hash("rotation"))
		gui.cancel_animation(node, hash("scale"))
		gui.cancel_animation(node, hash("color"))
		gui.cancel_animation(node, hash("size"))
	end

	local total = 0
	local done  = 0
	local function check()
		done = done + 1
		if done >= total and callback then callback() end
	end

	if preset.position then total = total + 1; gui.animate(node, hash("position"), to_vec(preset.position), easing, duration, delay, check) end
	if preset.rotation then total = total + 1; gui.animate(node, hash("rotation"), to_vec(preset.rotation), easing, duration, delay, check) end
	if preset.scale     then total = total + 1; gui.animate(node, hash("scale"),     to_vec(preset.scale),     easing, duration, delay, check) end
	if preset.color     then total = total + 1; gui.animate(node, hash("color"),     to_vec(preset.color),     easing, duration, delay, check) end
	if preset.size      then total = total + 1; gui.animate(node, hash("size"),      to_vec(preset.size),      easing, duration, delay, check) end

	if total == 0 and callback then callback() end
end

function M.conveyor(node, presets, callback)
	local i = 1
	local function step()
		if i > #presets then
			if callback then callback() end
			return
		end
		local p = presets[i]
		i = i + 1
		M.animate(node, p, step)
	end
	step()
end

function M.pack(tasks, callback)
	local total = #tasks
	local done  = 0
	if total == 0 then
		if callback then callback() end
		return
	end
	local function check()
		done = done + 1
		if done >= total and callback then callback() end
	end
	for _, t in ipairs(tasks) do
		M.animate(t.node, t.preset, check)
	end
end

function M.register_buttons(list)
	local buttons = { items = {}, locked = false }
	if not list then
		print("[Animator] WARNING: register_buttons got nil list")
		return buttons
	end
	for _, cfg in ipairs(list) do
		local ok, node = pcall(gui.get_node, cfg.node)
		if not ok or not node then
			print("[Animator] WARNING: node not found:", cfg.node)
		else
			M.apply(node, cfg.anim.default)
			table.insert(buttons.items, {
				node    = node,
				anim    = cfg.anim,
				action  = cfg.action,
				pressed = false,
				hovered = false,
			})
		end
	end
	return buttons
end

function M.reset_buttons(buttons)
	if not buttons then return end
	buttons.locked = false
	for _, btn in ipairs(buttons.items) do
		btn.pressed = false
		btn.hovered = false
		M.apply(btn.node, btn.anim.default)
	end
end

function M.handle_buttons(buttons, action_id, action)
	if not buttons then
		print("[Animator] WARNING: handle_buttons got nil")
		return false
	end
	if action_id ~= hash("touch") and action_id ~= nil then return false end
	if not action then return false end

	if buttons.locked then return true end

	local pressed_btn = nil
	for _, btn in ipairs(buttons.items) do
		if btn.pressed then pressed_btn = btn; break end
	end

	if action.released then
		if pressed_btn then
			pressed_btn.pressed = false
			local over = gui.pick_node(pressed_btn.node, action.x, action.y)

			if over then
				buttons.locked = true
				M.animate(pressed_btn.node, pressed_btn.anim.released, function()
					pressed_btn.action()
					buttons.locked = false
				end)
			else
				M.animate(pressed_btn.node, pressed_btn.anim.hover_off)
			end
			return true
		end
		return false
	end

	if pressed_btn then return true end

	for _, btn in ipairs(buttons.items) do
		local over = gui.pick_node(btn.node, action.x, action.y)

		if action.pressed and over then
			btn.pressed = true
			M.animate(btn.node, btn.anim.pressed)
			return true
		end

		if not action.pressed then
			if over and not btn.hovered then
				btn.hovered = true
				M.animate(btn.node, btn.anim.hover)
			elseif not over and btn.hovered then
				btn.hovered = false
				M.animate(btn.node, btn.anim.hover_off)
			end
		end
	end

	return false
end

return M