--- === Caffeine ===
local obj = {
	hs = hs,
}
obj.__index = obj

-- Metadata
obj.name = "Caffeine"
obj.version = "1.0"
obj.author = "ivaquero"
obj.license = "MIT"

-- Caffeine
local CaffeineMenubarItem = hs.menubar.new()

-- Set the icon of the menubar.
function obj:setCaffeineDisplay(state)
	if state then
		CaffeineMenubarItem:setIcon("images/active.pdf")
	else
		CaffeineMenubarItem:setIcon("images/inactive.pdf")
	end
end

-- Click the menubar icon, which toggles the caffeine state and menubar icon.
function obj:MenubarClicked()
	obj:setCaffeineDisplay(hs.caffeinate.toggle("displayIdle"))
end

-- Turns the caffeine state to off.
function obj:caffeineOff()
	hs.caffeinate.set("displayIdle", false, true)
	obj:setCaffeineDisplay(false)
end

-- Introduce url event for toggling caffeine state.
hs.urlevent.bind("caffeine-toggle", function()
	obj:setCaffeineDisplay(hs.caffeinate.toggle("displayIdle"))
end)

if CaffeineMenubarItem then
	-- Initialize callback
	CaffeineMenubarItem:setClickCallback(obj:MenubarClicked())

	-- Initialize display to current displayIdle value
	obj:setCaffeineDisplay(hs.caffeinate.get("displayIdle"))
end

local function onSleepWatcher(event)
	if event == hs.caffeinate.watcher.systemWillSleep then
		obj:caffeineOff()
	end
end

local SleepWatcher = hs.caffeinate.watcher.new(onSleepWatcher)
SleepWatcher:start()

return obj
