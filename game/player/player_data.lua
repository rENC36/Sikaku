local PlayerData = {}

local SAVE_PATH = "shikaku_player_data"

PlayerData.data = nil

local DEFAULT_DATA = {
	version = 1,
	levels = {
		easy   = {},
		medium = {},
		hard   = {},
	},
	settings = {
		sound = true,
		music = true,
	},
	stats = {
		games_played = 0,
		total_time = 0,
		best_time = nil,
	},
	last_category = "easy",
	last_page = 1,
}

function PlayerData.deepcopy(orig)
	local copy
	if type(orig) == "table" then
		copy = {}
		for k, v in next, orig, nil do
			copy[PlayerData.deepcopy(k)] = PlayerData.deepcopy(v)
		end
		setmetatable(copy, PlayerData.deepcopy(getmetatable(orig)))
	else
		copy = orig
	end
	return copy
end

function PlayerData.load()
	local loaded = sys.load(SAVE_PATH)
	if loaded and loaded.version then
		PlayerData.data = loaded
		print("[PlayerData] Loaded from disk")
	else
		PlayerData.data = {}
		for k, v in pairs(DEFAULT_DATA) do
			PlayerData.data[k] = type(v) == "table" and PlayerData.deepcopy(v) or v
		end
		print("[PlayerData] New save created")
	end
end

function PlayerData.save()
	if PlayerData.data then
		sys.save(SAVE_PATH, PlayerData.data)
	end
end

function PlayerData.get(path)
	if not PlayerData.data then PlayerData.load() end
	if not path then return PlayerData.data end
	local current = PlayerData.data
	for part in string.gmatch(path, "([^%.]+)") do
		local key = tonumber(part) or part
		if type(current) ~= "table" then return nil end
		current = current[key]
	end
	return current
end

function PlayerData.set(path, value)
	if not PlayerData.data then PlayerData.load() end
	local keys = {}
	for part in string.gmatch(path, "([^%.]+)") do
		table.insert(keys, tonumber(part) or part)
	end
	local current = PlayerData.data
	for i = 1, #keys - 1 do
		local key = keys[i]
		if type(current[key]) ~= "table" then current[key] = {} end
		current = current[key]
	end
	current[keys[#keys]] = value
end

function PlayerData.is_level_completed(category, level_index)
	local completed = PlayerData.get("levels." .. category)
	return completed and completed[level_index] == true
end

function PlayerData.complete_level(category, level_index)
	PlayerData.set("levels." .. category .. "." .. level_index, true)
	PlayerData.save()
	print("[PlayerData] Completed:", category, level_index)
end

function PlayerData.get_current_level(category)
	local completed = PlayerData.get("levels." .. category) or {}
	local i = 1
	while completed[i] do
		i = i + 1
	end
	return i
end

function PlayerData.get_completed_count(category)
	local completed = PlayerData.get("levels." .. category) or {}
	local count = 0
	for _ in pairs(completed) do count = count + 1 end
	return count
end

PlayerData.load()

return PlayerData