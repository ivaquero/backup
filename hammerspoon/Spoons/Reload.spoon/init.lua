--- === Reload ===
local obj = {
    hs = hs
 }
obj.__index = obj

-- Metadata
obj.name = "Reload"
obj.version = "1.0"
obj.author = "ivaquero"
obj.license = "MIT"

local function reloadConfig( paths )
    local doReload = false
    for _, file in pairs( paths ) do
        if file:sub( -4 ) == ".lua" then
            print( "A lua config file changed, reload" )
            doReload = true
        end
    end
    if not doReload then
        print( "No lua file changed, skipping reload" )
        return self
    end

    self.hs.reload()
end

local configFileWatcher = hs.pathwatcher.new( os.getenv( "HOME" ) .. "/.hammerspoon/", reloadConfig )
configFileWatcher:start()

return obj
