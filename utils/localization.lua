local Localization = {}
local PlayerData = require("game.player.player_data")

local LANG_MODULES = {
	en = require("data.localization.en_lang"),
	ru = require("data.localization.ru_lang"),
}

local _current_lang = "en"
local _data = {}

function Localization.init()
	_current_lang = PlayerData.get("settings.language") or "en"
	Localization.load(_current_lang, false)
end

function Localization.load(lang, save)
	save = save ~= false
	_current_lang = lang
	local module = LANG_MODULES[lang]
	if module then
		_data = module
		if save then
			PlayerData.set("settings.language", lang)
			PlayerData.save()
		end
		print("[Localization] Loaded:", lang)
	else
		print("[Localization] Failed to load:", lang)
		_data = {}
	end
end

function Localization.get(key)
	return _data[key] or key
end

function Localization.get_current()
	return _current_lang
end

function Localization.set_text(node_or_id, key)
	local node = node_or_id
	if type(node_or_id) == "string" then
		local ok, n = pcall(gui.get_node, node_or_id)
		if not ok or not n then
			print("[Localization] Node not found:", node_or_id)
			return
		end
		node = n
	end
	local ok_type, node_type = pcall(gui.get_type, node)
	if ok_type and node_type ~= gui.TYPE_TEXT then
		print("[Localization] Skipped (not text):", key or "?")
		return
	end
	gui.set_text(node, Localization.get(key or ""))

	return Localization.get(key or "")
end

function Localization.apply_to_gui(screen)
	local scope = screen and _data[screen] or _data
	for key, text in pairs(scope) do
		local ok, node = pcall(gui.get_node, key)
		if ok and node then
			gui.set_text(node, text)
		end
	end
end

return Localization