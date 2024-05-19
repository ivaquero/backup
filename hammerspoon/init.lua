-- Reload
function reloadConfig( paths )
    doReload = false
    for _, file in pairs( paths ) do
        if file:sub( -4 ) == ".lua" then
            print( "A lua config file changed, reload" )
            doReload = true
        end
    end
    if not doReload then
        print( "No lua file changed, skipping reload" )
        return
    end

    hs.reload()
end

configFileWatcher = hs.pathwatcher.new( os.getenv( "HOME" ) .. "/.hammerspoon/", reloadConfig )
configFileWatcher:start()

-- Window
hs.loadSpoon( "ShiftIt" )
spoon.ShiftIt:bindHotkeys( {} )

-- Volume
hs.loadSpoon( "Volume" )

hs.hotkey.bind( { 'ctrl', 'shift' }, "Down", function()
    spoon.Volume:changeVolume( 3 )
end )

hs.hotkey.bind( { 'ctrl', 'shift' }, "Up", function()
    spoon.Volume:changeVolume( -3 )
end )

-- Caffeine
hs.loadSpoon( "Caffeine" )

hs.hotkey.bind( { 'ctrl', 'shift' }, "W", function()
    spoon.Caffeine:start()
end )

hs.hotkey.bind( { 'ctrl', 'shift' }, "S", function()
    spoon.Caffeine:stop()
end )
