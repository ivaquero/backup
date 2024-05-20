--- === Volume ===
local obj = {
    hs = hs
 }
obj.__index = obj

-- Metadata
obj.name = "Volume"
obj.version = "1.0"
obj.author = "ivaquero"
obj.license = "MIT"

function obj:changeVolume( diff )
    local current = hs.audiodevice.defaultOutputDevice():volume()
    local new = math.min( 100, math.max( 0, math.floor( current + diff ) ) )
    if new > 0 then
        hs.audiodevice.defaultOutputDevice():setMuted( false )
    end
    hs.alert.closeAll( 0.0 )
    hs.alert.show( "Volume " .. new .. "%", {}, 0.3 )
    hs.audiodevice.defaultOutputDevice():setVolume( new )
    return self
end

return obj
