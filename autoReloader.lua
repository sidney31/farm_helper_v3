require 'lib.sampfuncs'

function onSystemMessage(msg, type, script)
    if msg:find('farm_helper_v3.lua: Script died due to an error.') then
            script.load("farm_helper_v3.lua")
    end
end