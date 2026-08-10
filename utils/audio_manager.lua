local AudioManager = {}

local PlayerData = require("game.player.player_data")

AudioManager.SOUNDS = {}
AudioManager.MUSICS = {}

local _sound_on = true
local _music_on = true
local _pending_music_url = nil 
local _playing_music_url = nil   

function AudioManager.init()
	_sound_on = PlayerData.get("settings.sound") ~= false
	_music_on = PlayerData.get("settings.music") ~= false
end

function AudioManager.is_sound_enabled() return _sound_on end
function AudioManager.is_music_enabled() return _music_on end

function AudioManager.set_sound_enabled(enabled)
	if _sound_on == enabled then return end
	_sound_on = enabled
	PlayerData.set("settings.sound", enabled)
	PlayerData.save()
end

function AudioManager.set_music_enabled(enabled)
	if _music_on == enabled then return end
	_music_on = enabled
	PlayerData.set("settings.music", enabled)
	PlayerData.save()

	if _music_on and _pending_music_url and _pending_music_url ~= _playing_music_url then
		AudioManager._play_now(_pending_music_url)
	elseif not _music_on and _playing_music_url then
		sound.stop(_playing_music_url)
		_playing_music_url = nil
	end
end

function AudioManager.toggle_sound() AudioManager.set_sound_enabled(not _sound_on) end
function AudioManager.toggle_music() AudioManager.set_music_enabled(not _music_on) end

function AudioManager.play_sound(url, properties)
	if not _sound_on or not url then return nil end
	return sound.play(url, properties or {})
end

function AudioManager.play_sound_id(id, properties)
	local url = AudioManager.SOUNDS[id]
	if not url then print("[AudioManager] Sound not found:", id) return nil end
	return AudioManager.play_sound(url, properties)
end

function AudioManager._play_now(url, properties)
	if _playing_music_url then
		sound.stop(_playing_music_url)
	end
	local handle = sound.play(url, properties or { gain = 0.5 })
	if handle then
		_playing_music_url = url
	end
	return handle
end

function AudioManager.play_music(url, properties)
	if not url then return nil end
	_pending_music_url = url

	if not _music_on then
		return nil
	end

	if _playing_music_url == url then
		return true
	end

	return AudioManager._play_now(url, properties)
end

function AudioManager.play_music_id(id, properties)
	local url = AudioManager.MUSICS[id]
	if not url then print("[AudioManager] Music not found:", id) return nil end
	return AudioManager.play_music(url, properties)
end

function AudioManager.stop_music()
	if _playing_music_url then
		sound.stop(_playing_music_url)
		_playing_music_url = nil
	end
end

return AudioManager