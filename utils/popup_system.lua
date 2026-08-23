local PopupCFG = require("data.config.popup_config")

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

--- Зарегистрировать GUI попапа (можно менять динамически)
function PopupSystem:register_gui(gui_url)
	self.gui_url = gui_url
end

--- Открыть попап по типу
-- @param popup_type ключ из PopupCFG.types
-- @param params таблица подстановок для текста, например { balance = 5 }
-- @return true если открылся
function PopupSystem:open(popup_type, params)
	if not self.can_work then
		print("[PopupSystem] Blocked: can_work is false")
		return false
	end
	if self.is_open then
		print("[PopupSystem] Blocked: already open")
		return false
	end

	local config = PopupCFG.types[popup_type]
	if not config then
		print("[PopupSystem] Unknown type:", popup_type)
		return false
	end

	self.is_open = true
	self.current = {
		type = popup_type,
		config = config,
		params = params or {},
	}

	-- Подстановка {ключ} в текст
	local text = config.text
	for k, v in pairs(params or {}) do
		text = text:gsub("{" .. k .. "}", tostring(v))
	end

	msg.post(self.gui_url, "show_popup", {
		title = config.title,
		text = text,
		yes_label = config.yes_label,
		no_label = config.no_label,
		show_yes = config.show_yes,
		show_no = config.show_no,
	})

	return true
end

--- Закрыть принудительно
function PopupSystem:close()
	self.is_open = false
	self.current = nil
	if self.gui_url then
		msg.post(self.gui_url, "hide_popup")
	end
end

--- Нажата кнопка (вызывается из main.script)
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

--- Блокирует ли текущий попап игровой input
function PopupSystem:pauses_input()
	if not self.current then return false end
	return self.current.config.pause_input == true
end

return PopupSystem