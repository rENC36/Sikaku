local PopupCFG = require("data.config.popup_config")
local Localization = require("utils.localization")

local PopupSystem = {}
PopupSystem.__index = PopupSystem

function PopupSystem.new()
	local self = setmetatable({}, PopupSystem)
	self.can_work = true
	self.is_open = false
	self.current = nil
	self.gui_url = nil
	return self
end

function PopupSystem:register_gui(gui_url)
	self.gui_url = gui_url
end

local function loc(value, params)
	if not value then return nil end
	local text = Localization.get(value) or value
	if params then
		for k, v in pairs(params) do
			text = text:gsub("{" .. k .. "}", tostring(v))
		end
	end
	return text
end

function PopupSystem:open(popup_type, params)
	if not self.can_work then
		return false
	end
	if self.is_open then
		return false
	end

	local config = PopupCFG.types[popup_type]
	if not config then
		return false
	end

	self.is_open = true
	self.current = {
		type = popup_type,
		config = config,
		params = params or {},
	}

	msg.post(self.gui_url, "show_popup", {
		title = loc(config.title, params),
		text = loc(config.text, params),
		yes_label = loc(config.yes_label),
		no_label = loc(config.no_label),
		show_yes = config.show_yes,
		show_no = config.show_no,
	})

	return true
end

function PopupSystem:close()
	self.is_open = false
	self.current = nil
	if self.gui_url then
		msg.post(self.gui_url, "hide_popup")
	end
end

function PopupSystem:on_button(button)
	if not self.current then return end
	local config = self.current.config

	if button == "yes" and config.yes_event then
		msg.post("/main", config.yes_event, self.current.params or {})
	elseif button == "no" and config.no_event then
		msg.post("/main", config.no_event, self.current.params or {})
	end

	self:close()
end

function PopupSystem:pauses_input()
	if not self.current then return false end
	return self.current.config.pause_input == true
end

return PopupSystem