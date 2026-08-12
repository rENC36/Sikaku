local ScreenManager = {}
ScreenManager.__index = ScreenManager

function ScreenManager.new()
	local self = setmetatable({}, ScreenManager)
	self.screens = {}
	self.current = nil
	return self
end

function ScreenManager:register(name, url)
	self.screens[name] = url
end

function ScreenManager:open(name)
	if self.current == name then return end
	for _, url in pairs(self.screens) do
		msg.post(url, "disable")
	end
	local url = self.screens[name]
	if url then
		msg.post(url, "enable")
		msg.post(url, "reset_ui")
		msg.post(url, "acquire_input_focus")
		self.current = name
		print("[ScreenManager] Opened:", name)
	else
		print("[ScreenManager] ERROR: Unknown screen:", name)
	end
end

return ScreenManager