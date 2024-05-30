-- Reload
hs.loadSpoon( "Reload" )

-- Window
hs.loadSpoon( "ShiftIt" )
spoon.ShiftIt:bindHotkeys( {} )

-- Volume
hs.loadSpoon( "Volume" )

hs.hotkey.bind( { 'ctrl', 'shift' }, "Down", function()
    spoon.Volume:changeVolume( -3 )
end )

hs.hotkey.bind( { 'ctrl', 'shift' }, "Up", function()
    spoon.Volume:changeVolume( 3 )
end )

-- Caffeine
-- hs.loadSpoon( "Caffeine" )

-- hs.hotkey.bind( { 'ctrl', 'shift' }, "W", function()
--     spoon.Caffeine:setCaffeineDisplay( true )
-- end )
