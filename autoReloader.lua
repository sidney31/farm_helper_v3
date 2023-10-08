require 'lib.sampfuncs'

function onSystemMessage(msg, type, script)
    if msg:find('farm_helper_v3.lua:%d+:.+') and type == 3 then
            script.load("farm_helper_v3.lua")
    end
end