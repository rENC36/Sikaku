local ScreenManager = {}
ScreenManager.__index = ScreenManager

function ScreenManager.new()
	local self = setmetatable({}, ScreenManager)
	self.screens = {}   -- имя -> URL
	self.active = nil   -- текущий экран
	self.stack = {}     -- стек для push/pop (например, меню → настройки → назад)
	return self
end

-- Зарегистрировать экран
function ScreenManager:register(name, url)
	self.screens[name] = url
end

-- Переключиться на экран (скрыть текущий, показать новый)
function ScreenManager:go_to(name, data)
	local url = self.screens[name]
	if not url then
		print("[ScreenManager] ERROR: screen not found:", name)
		return false
	end

	-- Скрываем текущий
	if self.active and self.active ~= name then
		local current = self.screens[self.active]
		if current then
			msg.post(current, "disable")
			msg.post(current, "screen_hide")
		end
	end

	-- Показываем новый
	msg.post(url, "enable")
	msg.post(url, "screen_show", data or {})

	self.active = name
	print("[ScreenManager] Switched to:", name)
	return true
end

-- Положить текущий в стек и открыть новый (например, из меню в настройки)
function ScreenManager:push(name, data)
	if self.active then
		table.insert(self.stack, self.active)
		local current = self.screens[self.active]
		if current then
			msg.post(current, "disable")
		end
	end
	return self:go_to(name, data)
end

-- Вернуться на предыдущий экран из стека
function ScreenManager:pop()
	if #self.stack == 0 then
		print("[ScreenManager] Stack empty")
		return false
	end

	local name = table.remove(self.stack)
	return self:go_to(name)
end

-- Получить имя активного экрана
function ScreenManager:get_active()
	return self.active
end

-- Скрыть все экраны
function ScreenManager:hide_all()
	for _, url in pairs(self.screens) do
		msg.post(url, "disable")
	end
	self.active = nil
	self.stack = {}
end

return ScreenManager