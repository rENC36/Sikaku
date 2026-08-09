local Levels = {}

Levels.banks = {
	easy = require("game.shikaku.levels.easy"),
}

Levels.index = {
	easy = 1,
}

function Levels.load(category)
	local bank = Levels.banks[category]
	if not bank then
		print("ERROR: No bank for category:", category)
		return nil
	end

	local idx = Levels.index[category] or 1
	if idx > #bank then
		idx = 1
		Levels.index[category] = 1
	end

	local puzzle = bank[idx]
	if not puzzle then
		print("ERROR: No puzzle at index", idx)
		return nil
	end

	Levels.index[category] = idx + 1
	print("Loading puzzle #", idx, "size:", puzzle.width.."x"..puzzle.height)
	return puzzle
end

function Levels.set_level(category, level_id)
	Levels.index[category] = level_id
end

function Levels.get(category, index)
	local bank = Levels.banks[category]
	return bank and bank[index] or nil
end

function Levels.count(category)
	local bank = Levels.banks[category]
	return bank and #bank or 0
end

return Levels