require 'lib.sampfuncs'
local farm_helper = require'farm_helper_v3'

function onSystemMessage(msg, type, script)
    if msg:find('farm_helper_v3.lua:%d+:.+') and type == 3 then
            script.load("farm_helper_v3.lua")
            farm_helper.afterReload()
    end
end

function main()
    while true do
        wait(0)
    end
end