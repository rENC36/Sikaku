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
		language = "en"
	},
	stats = {
		games_played = 0,
		total_time = 0,
		best_time = nil,
		blitz_best = 0,
	},
	hints = {
		balance = 3,
	},
	last_category = "easy", 
	last_page = 1,          
}

function PlayerData.load()
	local loaded = sys.load(SAVE_PATH)
	if loaded and loaded.version then
		PlayerData.data = loaded
		print("[PlayerData] Loaded from disk")
	else
		PlayerData.data = {}
		-- Копируем дефолт глубоко
		for k, v in pairs(DEFAULT_DATA) do
			PlayerData.data[k] = type(v) == "table" and PlayerData.deepcopy(v) or v
		end
		print("[PlayerData] Created new save")
	end
end

function PlayerData.save()
	if PlayerData.data then
		sys.save(SAVE_PATH, PlayerData.data)
		print("[PlayerData] Saved")
	end
end

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

function PlayerData.get(path)
	if not PlayerData.data then PlayerData.load() end
	if not path then return PlayerData.data end

	local keys = {}
	for part in string.gmatch(path, "([^%.]+)") do
		table.insert(keys, tonumber(part) or part)
	end

	local current = PlayerData.data
	for _, key in ipairs(keys) do
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
		if type(current[key]) ~= "table" then
			current[key] = {}
		end
		current = current[key]
	end
	current[keys[#keys]] = value
end

function PlayerData.is_level_completed(category, level_index)
	local completed = PlayerData.get("levels." .. category)
	if not completed then return false end
	return completed[level_index] == true
end

function PlayerData.complete_level(category, level_index)
	PlayerData.set("levels." .. category .. "." .. level_index, true)
	PlayerData.save()
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