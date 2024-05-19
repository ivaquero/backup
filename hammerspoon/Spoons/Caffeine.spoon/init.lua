--- === Caffeine ===
---
--- Prevent the screen from going to sleep
--- Download: [https://github.com/Hammerspoon/Spoons/raw/master/Spoons/Caffeine.spoon.zip](https://github.com/Hammerspoon/Spoons/raw/master/Spoons/Caffeine.spoon.zip)
local obj = {
    __gc = true
 }

setmetatable( obj, obj )
obj.__gc = function( t )
    t:stop()
end

-- Metadata
obj.name = "Caffeine"
obj.version = "1.0"
obj.author = "Chris Jones <cmsj@tenshu.net>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.menuBarItem = nil
obj.hotkeyToggle = nil

-- Internal function used to find our location, so we know where to load files from
local function script_path()
    local str = debug.getinfo( 2, "S" ).source:sub( 2 )
    return str:match( "(.*/)" )
end
obj.spoonPath = script_path()

function obj:init()
end

function obj:bindHotkeys( mapping )
    if (self.hotkeyToggle) then
        self.hotkeyToggle:delete()
    end
    local toggleMods = mapping["toggle"][1]
    local toggleKey = mapping["toggle"][2]
    self.hotkeyToggle = hs.hotkey.new( toggleMods, toggleKey, function()
        self.clicked()
    end )

    return self
end

function obj:start()
    if self.menuBarItem then
        self:stop()
    end
    self.menuBarItem = hs.menubar.new()
    self.menuBarItem:setClickCallback( self.clicked )
    if (self.hotkeyToggle) then
        self.hotkeyToggle:enable()
    end
    self.setDisplay( hs.caffeinate.get( "displayIdle" ) )

    return self
end

function obj:stop()
    if self.menuBarItem then
        self.menuBarItem:delete()
    end
    if (self.hotkeyToggle) then
        self.hotkeyToggle:disable()
    end
    self.menuBarItem = nil
    return self
end

function obj.setDisplay( state )
    local result
    if state then
        result = obj.menuBarItem:setIcon( obj.spoonPath .. "/caffeine-on.pdf" )
    else
        result = obj.menuBarItem:setIcon( obj.spoonPath .. "/caffeine-off.pdf" )
    end
end

function obj.clicked()
    obj.setDisplay( hs.caffeinate.toggle( "displayIdle" ) )
end

function obj:setState( on )
    hs.caffeinate.set( "displayIdle", on )
    obj.setDisplay( on )
end

return obj
