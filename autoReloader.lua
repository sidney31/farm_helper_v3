require 'lib.sampfuncs'

function onSystemMessage(msg, type, script)
    if msg:find('farm_helper_v3.lua') and msg:find('Script died due to an error.') then
        sampAddChatMessage('SCRIPTS CRASHED', -1)
        print('SCRIPTS CRASHED')
        script.load("farm_helper_v3.lua")
    end
end