-- Менеджер попапов — вызывай из любого скрипта
local M = {}

-- Путь к GUI с попапом. Поменяй если у тебя другой путь.
M.POPUP_URL = "/popup#popup"

--- Показать попап
-- @param config таблица:
--   title          - заголовок
--   text           - основной текст
--   buttons        - массив кнопок {id="ok", label="OK", node="btn_ok", ...}
--   callback_url   - куда отправить ответ (по умолчанию "/main")
--   popup_id       - идентификатор попапа для различения ответов
--   dismissible    - можно ли закрыть по клику вне окна (default: true)
function M.show(config)
	msg.post(M.POPUP_URL, "show_popup", config or {})
end

--- Скрыть попап
function M.hide()
	msg.post(M.POPUP_URL, "hide_popup")
end

--- Быстрый попап с одной кнопкой OK
function M.alert(text, title, callback_url)
	M.show({
		title = title or "Внимание",
		text = text,
		buttons = { { id = "ok", label = "OK", node = "btn_ok" } },
		callback_url = callback_url,
	})
end

--- Подтверждение (OK / Отмена)
function M.confirm(text, title, callback_url)
	M.show({
		title = title or "Подтверждение",
		text = text,
		buttons = {
			{ id = "ok",     label = "OK",     node = "btn_ok" },
			{ id = "cancel", label = "Отмена", node = "btn_cancel" },
		},
		callback_url = callback_url,
	})
end

return M