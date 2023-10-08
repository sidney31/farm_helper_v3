--[[

   _____  _      _                      ____  __ 
  / ____|(_)    | |                    |___ \/_ |
 | (___   _   __| | _ __    ___  _   _   __) || |
  \___ \ | | / _  ||  _ \  / _ \| | | | |__ < | |
  ____) || || (_| || | | ||  __/| |_| | ___) || |
 |_____/ |_| \__,_||_| |_| \___| \__, ||____/ |_|
                                  __/ |
                                 |___/
sandro
]]

script_name("farm_helper_v3.lua")
script_version("09.10.2023")

local enable_autoupdate = true
local autoupdate_loaded = false
local Update = nil
if enable_autoupdate then
    local updater_loaded, Updater = pcall(loadstring)
    if updater_loaded then
        autoupdate_loaded, Update = pcall(Updater)
        if autoupdate_loaded then
            Update.json_url = "https://raw.githubusercontent.com/sidney31/farm_helper_v3/main/update.json" .. tostring(os.clock())
            Update.prefix = "[" .. string.upper(thisScript().name) .. "]: "
            Update.url = "https://github.com/qrlk/moonloader-script-updater/"
        end
    end
end

local Telegram = require('dolbogram')
local encoding = require('encoding')
encoding.default = 'CP1251'
local u8 = encoding.UTF8

local fa = require("fAwesome5")
local ffi = require('ffi')
local imgui = require('mimgui')
local new, str, sizeof = imgui.new, ffi.string, ffi.sizeof
local sampev = require 'lib.samp.events'

local inicfg = require("inicfg")
local directIni = ('afkhelper.ini')
local ini = inicfg.load(inicfg.load({
    tg = {
        id = '',
        token = '',
    },
}, directIni))
inicfg.save(ini, directIni)
local bot = Telegram(ini.tg.token)

local settings = {
    token = new.char[256](u8:decode(ini.tg.token)),
    id = new.char[256](u8:decode(ini.tg.id)),
    renderWindow = false,
    tgWindow = new.bool(),
}

local az = ''
local hp = ''
local lvl = ''
local exp = ''
local money = ''
local bank = ''
local deposite = ''
local sNotif ='-����������-\n'

local n_deppd = ''
local n_alldeppd = ''
local n_bankpd = ''
local n_allbankpd = ''
local n_lvl, n_exp = '', ''
local pdNotif = '-PayDay-'

local out = ''
local stats = false

local roulettes = false
local box, boxtime = 0, 0
local dbox, dboxtime = 0, 0
local pbox, pboxtime = 0, 0
local tmask, tmasktime = 0, 0
local tls, tlstime = 0, 0
local use = 0
local close = 0
local wbook = false;
local chatTranslate = false;

local resX, resY = getScreenResolution()

function msg(...) sampAddChatMessage(table.concat({...}, '  '), -1) end

bot:connect()

bot:on('message', function(message)
    if message.text == '/start' then
        bot:sendMessage{chat_id = tonumber(ini.tg.id), text = u8('���������� ��������'), reply_markup = {
            keyboard = {
                { { text = u8('������� �������') }, {text=u8('����� � �����������')} },
                { { text = u8('����������') }, { text = u8('�������� � ��������') } },
                { { text = u8('��������/��������� ���������� ����') } },
            }
        }}
    elseif message.text == u8('������� �������') then
        openKeys()
    elseif message.text == u8('����������') then
        getStats()
    elseif message.text == u8('�������� � ��������') then
        bot:sendMessage{chat_id = tonumber(ini.tg.id), text = u8('��� ������ �������?'), reply_markup = {
            inline_keyboard = {
                { { text = u8('���������'), callback_data = 'rec' }, { text = u8('�����'), callback_data = 'quit' } },
            }
        }}
    elseif message.text == u8('����� � �����������') then
        checkHoursInOrganization()
    elseif message.text == u8('��������/��������� ���������� ����') then
        changeStateOfChatTranslate()
    elseif chatTranslate then
        sampSendChat(u8:decode(message.text))
    else
        bot:sendMessage{chat_id = tonumber(ini.tg.id), text = u8('����������� �������')}
    end
end)

bot:on('callback_query', function(query)
    if query.data == 'rec' then
        sampSendChat('/rec')
        bot:sendMessage{chat_id = tonumber(ini.tg.id), text = u8('�������� ���������')}
    elseif query.data == 'quit' then
        sampProcessChatInput('/q')
        bot:sendMessage{chat_id = tonumber(ini.tg.id), text = u8('���� �������')}
    elseif query.data == 'chatTranslate' then
        changeStateOfChatTranslate()
    end
end)

function changeStateOfChatTranslate()
    chatTranslate = not chatTranslate
    bot:sendMessage{chat_id = tonumber(ini.tg.id), text = u8('���������� ���� '..(chatTranslate and '��������' or '���������')..', ��������� ���� ��������� '..(chatTranslate and '�����' or '�� �����')..' ���������� � ������� ���')}
end

function openKeys()
    roulettes = true
    sampSendChat('/report')
    wait(200)
    sampSendDialogResponse(32, 0, -1, 123)
    wait(300)
    
    if sampTextdrawIsExists(close) then
        sampSendClickTextdraw(close)
    end

    wait(300)
    sampSendChat('/invent')

    local boxes={box, pbox, dbox, tmask, tls}

    for i = 1, #boxes, 1 do
        wait(500)
        sampSendClickTextdraw(boxes[i])
        wait(500)
        sampSendClickTextdraw(use + 1)
    end
    roulettes = false
end

function getStats()
    sNotif ='-����������-\n'
    sampSendChat('/stats')
    stats = true
end

function checkHoursInOrganization()
    local result = -1;
    sampSendChat('/wbook')
    wbook = true;
    return result;
end

function separator(n)
    n = tostring(n)
    local left, num, right = string.match(n, '^([^%d]*%d)(%d*)(.-)$')
    return left .. (num:reverse():gsub('(%d%d%d)', '%1,'):reverse()) .. right
end

function sampev.onShowTextDraw(id, data)
    -------------------------------------------�������-------------------------------------------
    --if id == 2112 then sampSetChatInputText(data.text) end
    if data.modelId == 19918 then box = id end
    if data.modelId == 19613 then dbox = id end
    if data.modelId == 1353 then pbox = id end
    if data.modelId == 1733 then tmask = id end
    if data.modelId == 2887 then tls = id end
    if data.text == 'USE' or data.text == '�C�O���O�A��' then use = id end
    if data.text == 'CLOSE' and data.style == 2 or data.text == '�AKP���' and data.style == 2 then close = id - 1 end
    if roulettes then
        if data.text:find('(%d+) min') and ini.boxes.box and id == tonumber(box) + 1 then
            boxtime = data.text:match('(%d+)') 
            bot:sendMessage{chat_id = tonumber(ini.tg.id), text = u8('�� �������� ������� �������� ' .. boxtime .. ' �����.')}
        end
        if data.text:find('(%d+) min') and ini.boxes.dbox and id == tonumber(dbox) + 1 then
            dboxtime = data.text:match('(%d+)') 
            bot:sendMessage{chat_id = tonumber(ini.tg.id), text = u8('�� �������� ��������� ������� �������� ' .. dboxtime .. ' �����.')}
        end
        if data.text:find('(%d+) min') and ini.boxes.pbox and id == tonumber(pbox) + 1 then
            pboxtime = data.text:match('(%d+)') 
            bot:sendMessage{chat_id = tonumber(ini.tg.id), text = u8('�� �������� ����������� ������� �������� ' .. pboxtime .. ' �����.')}
        end
        if data.text:find('(%d+) min') and ini.boxes.tmask and id == tonumber(tmask) + 1 then
            tmasktime = data.text:match('(%d+)') 
            bot:sendMessage{chat_id = tonumber(ini.tg.id), text = u8('�� �������� ������� ����� ����� �������� ' .. tmasktime .. ' �����.')}
        end
        if data.text:find('(%d+) min') and ini.boxes.tls and id == tonumber(tls) + 1 then
            tlstime = data.text:match('(%d+)') 
            bot:sendMessage{chat_id = tonumber(ini.tg.id), text = u8('�� �������� ������� ���-������ �������� ' .. tlstime .. ' �����.')}
        end
    end
end

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
    sampAddChatMessage(dialogId, -1)
    
    if dialogId == 32 and roulettes then
        sampSendDialogResponse(dialogId, 0, -1, -1)
    end
    if dialogId == 235 then
        for line in text:gmatch("[^\n]+") do
            if line:find('������� ��������� �����: (.*) ') then
                az = line:match('(%d+)')
                sNotif = sNotif..'\n����� ����: '..az..' az'
            end
            if line:find('��������: %{......%}%[(%d+/%d+)%]') then
                hp = line:match('��������: %{......%}%[(%d+/%d+)%]')
                sNotif = sNotif..'\n��������: '..hp
            end
            if line:find('�������: %{......%}%[(%d+)%]') then
                lvl = line:match('�������: %{......%}%[(%d+)%]')
                sNotif = sNotif..'\n�������: '..lvl
            end
            if line:find('��������: %{......%}%[(%d+/%d+)%]') then
                exp = line:match('��������: %{......%}%[(%d+/%d+)%]')
                sNotif = sNotif..'\n��������: '..exp
            end
            if line:find('�������� ������ %(SA$%): %{......%}%[($%d+)%]') then
                money = line:match('�������� ������ %(SA$%): %{......%}%[($%d+)%]')
                sNotif = sNotif..'\n������ �� �����: '..separator(money)
            end
            if line:find('�������� ������ %(VC$%): %{......%}%[($%d+)%]') then
                money = line:match('�������� ������ %(VC$%): %{......%}%[($%d+)%]')
                sNotif = sNotif..'\n������ �� �����: '..separator(money)..' SA$'
            end
            if line:find('������ � �����: %{......%}%[($%d+)%]') then
                bank = line:match('������ � �����: %{......%}%[($%d+)%]')
                sNotif = sNotif..'\n������ � �����: '..separator(bank)..' VC$'
            end
            if line:find('������ �� ��������: %{......%}%[($%d+)%]') then
                deposite = line:match('������ �� ��������: %{......%}%[($%d+)%]')
                sNotif = sNotif..'\n������� ����: '..separator(deposite)
            end
        end
    end
    if stats then
        stats = false
        bot:sendMessage{chat_id = tonumber(ini.tg.id), text = u8(sNotif)}
        sampSendDialogResponse(0, 1, 0, -1)
    end

    if dialogId == 0 and text:find('�����!') then
        sampSendDialogResponse(0, 1, 0, -1)
    end

    if dialogId == 25228 and wbook then
        sampSendDialogResponse(dialogId, 1, 0, -1)
    end
    if dialogId == 25627 and wbook then
        if text:find('(%d+) �����') then
            local hours = text:match('(%d+) �����')
            bot:sendMessage{chat_id = tonumber(ini.tg.id), text = u8('�� ������� �������� '..hours..' �����')}
        end
        wbook = false
    end
end

function sampev.onServerMessage(color, text)
    if chatTranslate then
        bot:sendMessage{chat_id = tonumber(ini.tg.id), text = u8(text)}
    end

    if text:find('����� ���������� �� Arizona Role Play!')  then
        bot:sendMessage{chat_id = tonumber(ini.tg.id), text = u8('�� �������������� � �������!')}
    end

    if text:find('_____���������� ���_____') then
        pdNotif = '-PayDay-'
    end
    if text:find('������� � �����: $(%d+)') then
        n_alldeppd = text:match('������� � �����: $(%d+)')
        pdNotif = pdNotif..'\n������� � �����: '..separator(n_alldeppd)
    end
    if text:find('����� � �������: $(%d+)') then
        n_bankpd = text:match('����� � �������: $(%d+)')
        pdNotif = pdNotif..'\n����� � �������: '..separator(n_bankpd)
    end
    if text:find('������� ����� � �����: $(%d+)') then
        n_allbankpd = text:match('������� ����� � �����: $(%d+)')
        pdNotif = pdNotif..'\n������� ����� � �����: '..separator(n_allbankpd)
    end
    if text:find('������� ����� �� ��������: $(%d+)') then
        n_deppd = text:match('������� ����� �� ��������: $(%d+)')
        pdNotif = pdNotif..'\n������� ����� �� ��������: '..separator(n_deppd)
    end
    if text:find('� ������ ������ � ��� (%d+)-� ������� � (%d+/%d+) ���������') then
        n_lvl, n_exp = text:match('� ������ ������ � ��� (%d+)-� ������� � (%d+/%d+) ���������')
        pdNotif = pdNotif..'\n�������: '..n_lvl..'. ��������: '..n_exp
        bot:sendMessage{chat_id = tonumber(ini.tg.id), text = u8(pdNotif)}
    end
    if text:find('�� �������� ������ %d+ ����� ��� ���!') then
        bot:sendMessage{chat_id = tonumber(ini.tg.id), text = u8'������ �� ��� �������, '..text}
    end

    if roulettes then
        if text:find('�� ������������ ������ � ��������� � �������� (.*)!') then
            out = text:match('�� ������������ ������ � ��������� � �������� (.*)!')
             bot:sendMessage{chat_id = tonumber(ini.tg.id), text = u8('������ ������ � ���������. �������� ' .. out .. '.')}
        end
        if text:find('�� ������������ ���������� ������ � ��������� � �������� (.*)!') then
            out = text:match('�� ������������ ���������� ������ � ��������� � �������� (.*)!')
             bot:sendMessage{chat_id = tonumber(ini.tg.id), text = u8('������ ���������� ������ � ���������. �������� ' .. out .. '.')}
        end
        if text:find('�� ������������ ������ ����� ����� � �������� (.*)!') then
            out = text:match('�� ������������ ������ ����� ����� � �������� (.*)!')
             bot:sendMessage{chat_id = tonumber(ini.tg.id), text = u8('������ ������ ����� �����. ������� ' .. out .. '.')}
        end
        if text:find('�� ������������ ������ ��� ������� � �������� (.*)!') then
            out = text:match('�� ������������ ������ ��� ������� � �������� (.*)!')
             bot:sendMessage{chat_id = tonumber(ini.tg.id), text = u8('������ ������ ��� �������. ������� ' .. out .. '.')}
        end
    end
    if text:find('�� ������ (.+) %((%d+) ��%.%) � ������ (%w+_%w+) �� $(%d+)') then
        local item, lot, name, sum = text:match('�� ������ (.+) %((%d+) ��%.%) � ������ (%w+_%w+) �� $(%d+)')
        local text = name .. ' ������ ' .. lot .. ' ' .. item .. ', �� �����: $' .. separator(tostring(sum))
        bot:sendMessage{chat_id = tonumber(ini.tg.id), text = u8(text)}
    end

    if text:find('(%w+_%w+) ����� � ��� (.+) %((%d+) ��%.%), �� �������� $(%d+) �� ������� %(�������� %d* �������%(�%)%)') then
        local name, item, lot, sum = text:match('(%w+_%w+) ����� � ��� (.+) %((%d+) ��%.%), �� �������� $(%d+) �� ������� %(�������� %d* �������%(�%)%)')
        local text = name .. ' ����� ' .. lot .. ' ' .. item .. ', �� �����: $' .. separator(tostring(sum))
        bot:sendMessage{chat_id = tonumber(ini.tg.id), text = u8(text)}
    end
end

function sampev.onSendTakeDamage(playerId, damage, weapon, bodypart)
    local id = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
    if playerId <= 999 and sampGetGamestate() == 3 then
        bot:sendMessage{chat_id = tonumber(ini.tg.id), text = u8('������� ���� �� '..sampGetPlayerNickname(playerId)..', ��� ������ '..sampGetGunNameById(weapon)..'\n�������� '..sampGetPlayerHealth(id)..' ������ ��������'), reply_markup = {
            inline_keyboard = {
                { { text = u8((chatTranslate and '���������' or '��������')..' ���������� ����'), callback_data = 'chatTranslate' } },
            }
        }}
    else
        bot:sendMessage{chat_id = tonumber(ini.tg.id), text = u8('������� ����������� ����. �������� '..sampGetPlayerHealth(id)..' ������ ��������')}
    end
end

function sampGetGunNameById(arg)
    local gunList = {
        '�����', '������', '������ ��� ������', '����������� �������', '���',
        '����������� ����', '������', '���', '������', '���������', '�����', 
        '�����', '��������', '��������', '����� ������', '������', '�������',
        '������������ ���', '�������� ��������', '�������� 9��',
        '�������� 9�� � ����������', '�������� ������ ���', '������� ��������', 
        '�����', '�������������� ��������', '���', 'MP5', '������� �����������',
        '�������� M4', 'Tec-9', '��������� �����', '����������� ��������', '���', 
        '��������������� ������ HS', '�������', '�������', '����� � ��������', 
        '��������� � �����', '��������� � �������', '������������', '�����������',
        '������ ������� �������', '����������', '�������'
    }
    return gunList[arg+1]
end

function save()
    ini.tg.id = u8:decode(str(settings.id))
    ini.tg.token = u8:decode(str(settings.token))
    inicfg.save(ini, directIni)
end

imgui.OnInitialize(function()
    imgui.DarkTheme()
    imgui.GetIO().IniFilename = nil
    local config = imgui.ImFontConfig()
    config.MergeMode = true
    local glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
    local iconRanges = imgui.new.ImWchar[3](fa.min_range, fa.max_range, 0)
    imgui.GetIO().Fonts:AddFontFromFileTTF('trebucbd.ttf', 14.0, nil, glyph_ranges)
    icon = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fa-solid-900.ttf', 15.0, config, iconRanges)
    mini = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 13.0, _, glyph_ranges)
    medium = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 20.0, _, glyph_ranges)
    mediumplus = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 18.0, _, glyph_ranges)
    big = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 30.0, _, glyph_ranges)
end)

imgui.OnFrame(function() return settings.renderWindow end,
    function()
        renderDrawBox(0, 0, resX, resY, 0x50000000)
        imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(400, 300), imgui.Cond.FirstUseEver)
        imgui.PushStyleColor(imgui.Col.ChildBg, imgui.ImVec4(0.48, 0.48, 0.48, 0.03))
        imgui.Begin('##window', _, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar)
        imgui.BeginChild('header', imgui.ImVec2(390, 30))
        imgui.PushFont(big)
        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.25, 0.25, 0.26, 0.0))
        imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0.25, 0.25, 0.26, 0.0))
        imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.25, 0.25, 0.26, 0.0))
        imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.25, 0.25, 0.26, 0.0))
        if imgui.Button('##AFK-FARMING HELPER', imgui.ImVec2(240, 30)) then
            tab = nil
        end
        imgui.SameLine()
        imgui.SetCursorPosX(5)
        imgui.SetCursorPosY(-5)
        imgui.Text('AFK-FARMING HELPER')
        imgui.PopStyleColor(4)
        imgui.PopFont()
        imgui.SameLine()
        imgui.PushStyleVarFloat(imgui.StyleVar.FrameRounding, 15)
        imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0.48, 0.48, 0.48, 0.00))
        imgui.SetCursorPosX(325)
        imgui.SetCursorPosY(0)
        if imgui.Button(fa.ICON_FA_PAPER_PLANE, imgui.ImVec2(30, 30)) then settings.tgWindow[0] = true
        settings.renderWindow = false
        end
        imgui.SameLine()
        if imgui.Button(fa.ICON_FA_TIMES, imgui.ImVec2(30, 30)) then settings.renderWindow = false end
        imgui.PopStyleVar(1)
        imgui.EndChild()
        imgui.PopStyleColor(1)
        imgui.PushStyleVarFloat(imgui.StyleVar.ChildBorderSize, 0)
        imgui.PushStyleColor(imgui.Col.ChildBg, imgui.ImVec4(0.48, 0.48, 0.48, 0.03))
        imgui.BeginChild('tabs', imgui.ImVec2(45, 255), true)
        imgui.SetCursorPosX(45 / 2 - 40 / 2)
        if tab == 1 then
            imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.25, 0.25, 0.26, 0.6))
        else
            imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.25, 0.25, 0.26, 0.0))
        end
        if imgui.Button(fa.ICON_FA_COG .. '##1', imgui.ImVec2(40, 40)) then tab = 1 end
        imgui.SetCursorPosX(45 / 2 - 40 / 2)
        if tab == 2 then
            imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.25, 0.25, 0.26, 0.6))
        else
            imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.25, 0.25, 0.26, 0.0))
        end
        if imgui.Button(fa.ICON_FA_BOXES .. '##2', imgui.ImVec2(40, 40)) then tab = 2 end
        imgui.SetCursorPosX(45 / 2 - 40 / 2)
        if tab == 3 then
            imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.25, 0.25, 0.26, 0.6))
        else
            imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.25, 0.25, 0.26, 0.0))
        end
        if imgui.Button(fa.ICON_FA_TASKS .. '##3', imgui.ImVec2(40, 40)) then tab = 3 end
        imgui.SetCursorPosX(45 / 2 - 40 / 2)
        if tab == 4 then
            imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.25, 0.25, 0.26, 0.6))
        else
            imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.25, 0.25, 0.26, 0.0))
        end
        if imgui.Button(fa.ICON_FA_FILE_ALT .. '##4', imgui.ImVec2(40, 40)) then tab = 4 end
        imgui.EndChild()
        imgui.PopStyleColor(4)
        imgui.SameLine()
        if tab == nil then
            imgui.BeginChild('tab0', imgui.ImVec2(340, 255), true)
            imgui.Separator()
            imgui.PushFont(medium)
            imgui.Text(u8 '��� ����� token?')
            imgui.PopFont()
            imgui.TextColored(imgui.ImVec4(0.9, 0.9, 0.9, 1.0), u8 'Token � ��� ���������� ������������� ������ ����.\n��� ��������� ������ ���������� � ��������� �����\n���� @BotFather � �������� ��� /newbot, ����� �����\n�������� � ����� ���� �� ������� ��������� �\n�������. �������� � ��������� � ���������.')
            imgui.Separator()
            imgui.PushFont(medium)
            imgui.Text(u8 '��� ����� id?')
            imgui.PopFont()
            imgui.TextColored(imgui.ImVec4(0.9, 0.9, 0.9, 1.0), u8 'Id � ��� ���������� ������������� ������ �������.\n��� ��������� id ���������� ����� ���� @my_id_bot\n� �������� ��� /start. ����� �� ������� ���������\n� ����� id. �������� � ��������� � ���������.')
            imgui.Separator()
            imgui.SetCursorPosX(243)
            imgui.TextDisabled(u8 '\n�����: Sidney31')
            imgui.SetCursorPosX(264)
            imgui.TextDisabled(u8 '������: 3.0;')
            imgui.EndChild()
        end
        -- if tab == 1 then
        --     imgui.BeginChild('tab1', imgui.ImVec2(340, 255), true)
        --     if imgui.Checkbox(u8 ' ����������� � ����� �� ������.', settings.joinNotif) then save() end
        --     if imgui.Checkbox(u8 ' �������������� �', settings.beforePd) then save() end
        --     imgui.PushItemWidth(22)
        --     imgui.SameLine()
        --     if imgui.InputInt("##1", settings.min, 0, 0) then save() end
        --     imgui.SameLine()
        --     if settings.min[0] == 1 then
        --         imgui.Text(u8 '-� ������ �� ������.')
        --     elseif settings.min[0] >= 2 and settings.min[0] <= 4 then
        --         imgui.Text(u8 '-� ������� �� ������.')
        --     elseif settings.min[0] == 24 or settings.min[0] == 34 or settings.min[0] == 44 or settings.min[0] == 54
        --         or settings.min[0] == 23 or settings.min[0] == 33 or settings.min[0] == 43 or settings.min[0] == 53 then
        --         imgui.Text(u8 '-�� ������� �� ������.')
        --     else
        --         imgui.Text(u8 '-� ������� �� ������.')
        --     end
        --     if imgui.Checkbox(u8 ' ����������� � ����������� � ������.', settings.pd) then save() end
        --     if imgui.Checkbox(u8 ' ����������� � ������ ���������.', settings.hungry) then save() end
        --     if imgui.Checkbox(u8 ' ������� ��� ������ ���������.', settings.autoeat) then save() end
        --     local method = imgui.new['const char*'][#methodList](methodList)
        --     imgui.PushItemWidth(225)
        --     if imgui.Combo('##method', settings.method, method, #methodList) then save() end
        --     imgui.PopItemWidth()
        --     imgui.EndChild()
        -- elseif tab == 2 then
        --     imgui.BeginChild('tab2', imgui.ImVec2(340, 255), true)
        --     if imgui.Checkbox(u8 ' ������ �������.', settings.box) then save() end
        --     if imgui.Checkbox(u8 ' ������ ������� (�����).', settings.dbox) then save() end
        --     if imgui.Checkbox(u8 ' ������ ���������� �������.', settings.pbox) then save() end
        --     if imgui.Checkbox(u8 ' ������ ����� �����.', settings.tmask) then save() end
        --     if imgui.Checkbox(u8 ' ������ ���-������.', settings.tls) then save() end
        --     imgui.EndChild()
        -- elseif tab == 3 then
        --     imgui.BeginChild('tab3', imgui.ImVec2(340, 255), true)
        --     imgui.PushFont(mediumplus)
        --     imgui.Text(u8 '����������:')
        --     imgui.PopFont()
        --     imgui.PushStyleVarFloat(imgui.StyleVar.FrameRounding, 15)
        --     imgui.PushFont(mini)
        --     if imgui.Checkbox(u8 '����� ����;', settings.sdonate) then save() end
        --     if imgui.Checkbox(u8 '��������;', settings.shp) then save() end
        --     if imgui.Checkbox(u8 '�������;', settings.ssat) then save() end
        --     if imgui.Checkbox(u8 '�������;', settings.slvl) then save() end
        --     if imgui.Checkbox(u8 '��������;', settings.sexp) then save() end
        --     if imgui.Checkbox(u8 '������ �� �����;', settings.smoney) then save() end
        --     if imgui.Checkbox(u8 '������ �� �����;', settings.sbank) then save() end
        --     if imgui.Checkbox(u8 '������ �� ��������;', settings.sdep) then save() end
        --     imgui.PopFont()
        --     imgui.Separator()
        --     imgui.PushFont(mediumplus)
        --     imgui.Text(u8 '������:')
        --     imgui.PopFont()
        --     imgui.PushFont(mini)
        --     if imgui.Checkbox(u8 '��������;', settings.payday) then save() end
        --     if imgui.Checkbox(u8 '��������� �����;', settings.bank) then save() end
        --     if imgui.Checkbox(u8 '�������� � ��������;', settings.depplus) then save() end
        --     if imgui.Checkbox(u8 '��������� ��������;', settings.depall) then save() end
        --     if imgui.Checkbox(u8 '������� � ��������;' .. '##2', settings.lvlexp) then save() end
        --     imgui.PopFont()
        --     imgui.PopStyleVar(1)
        --     imgui.EndChild()
        -- elseif tab == 4 then
        --     imgui.BeginChild('tab4', imgui.ImVec2(340, 255), true)
        --     imgui.PushItemWidth(340)
        --     if imgui.InputText("##tags", settings.tags, 256) then save() end
        --     if #str(settings.tags) == 0 then
        --         imgui.SameLine(325 / 2 - imgui.CalcTextSize(u8'�������� �����').x / 2)
        --         imgui.TextDisabled(u8'�������� �����')
        --     end
        --     if imgui.Checkbox(u8 '����������� � ������;', settings.damageN) then save() end
        --     if imgui.Checkbox(u8 '����������� �������/�������;', settings.buysellN) then save() end
        --     imgui.PopItemWidth()
        --     imgui.EndChild()
        -- end
        imgui.PopStyleVar(1)
    end)


imgui.OnFrame(function() return settings.tgWindow[0] end,
    function()
        renderDrawBox(0, 0, resX, resY, 0x99000000)
        imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(200, 100), imgui.Cond.FirstUseEver)
        imgui.Begin('##tgwindow', _, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse)
        imgui.PushItemWidth(190)
        if imgui.InputText('##token', settings.token, sizeof(settings.token)) then save() end
        if #str(settings.token) == 0 then
            imgui.SameLine(5 + 190 / 2 - imgui.CalcTextSize('Your Token').x / 2)
            imgui.TextDisabled('Your Token')
        end
        if imgui.InputText('##id', settings.id, sizeof(settings.id)) then save() end
        if #str(settings.id) == 0 then
            imgui.SameLine(5 + 190 / 2 - imgui.CalcTextSize('Your Id').x / 2)
            imgui.TextDisabled('Your Id')
        end
        imgui.PopItemWidth()
        imgui.SetCursorPosX(5 + 190 / 2 - 60 / 2)
        imgui.SetCursorPosY(70)
        if imgui.Button(fa.ICON_FA_CHECK, imgui.ImVec2(60, 23)) then
            settings.tgWindow[0] = false
            settings.renderWindow = true
        end
    end)

function imgui.DarkTheme() -- by chapo
    imgui.SwitchContext()
    --==[ STYLE ]==--
    imgui.GetStyle().WindowPadding = imgui.ImVec2(5, 5)
    imgui.GetStyle().FramePadding = imgui.ImVec2(5, 5)
    imgui.GetStyle().ItemSpacing = imgui.ImVec2(5, 5)
    imgui.GetStyle().ItemInnerSpacing = imgui.ImVec2(2, 2)
    imgui.GetStyle().TouchExtraPadding = imgui.ImVec2(0, 0)
    imgui.GetStyle().IndentSpacing = 0
    imgui.GetStyle().ScrollbarSize = 10
    imgui.GetStyle().GrabMinSize = 10

    --==[ BORDER ]==--
    imgui.GetStyle().WindowBorderSize = 0
    imgui.GetStyle().ChildBorderSize = 0
    imgui.GetStyle().PopupBorderSize = 0
    imgui.GetStyle().FrameBorderSize = 1
    imgui.GetStyle().TabBorderSize = 0

    --==[ ROUNDING ]==--
    imgui.GetStyle().WindowRounding = 0
    imgui.GetStyle().ChildRounding = 4
    imgui.GetStyle().FrameRounding = 5
    imgui.GetStyle().PopupRounding = 5
    imgui.GetStyle().ScrollbarRounding = 5
    imgui.GetStyle().GrabRounding = 5
    imgui.GetStyle().TabRounding = 5

    --==[ ALIGN ]==--
    imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().SelectableTextAlign = imgui.ImVec2(0.5, 0.5)

    --==[ COLORS ]==--
    imgui.GetStyle().Colors[imgui.Col.Text]                  = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextDisabled]          = imgui.ImVec4(0.50, 0.50, 0.50, 1.00)
    imgui.GetStyle().Colors[imgui.Col.WindowBg]              = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ChildBg]               = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PopupBg]               = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Border]                = imgui.ImVec4(0.25, 0.25, 0.26, 0.54)
    imgui.GetStyle().Colors[imgui.Col.BorderShadow]          = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBg]               = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]        = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgActive]         = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBg]               = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgActive]         = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed]      = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.MenuBarBg]             = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarBg]           = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab]         = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered]  = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive]   = imgui.ImVec4(0.51, 0.51, 0.51, 1.00)
    imgui.GetStyle().Colors[imgui.Col.CheckMark]             = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrab]            = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrabActive]      = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Button]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonHovered]         = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonActive]          = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Header]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderHovered]         = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderActive]          = imgui.ImVec4(0.47, 0.47, 0.47, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Separator]             = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorHovered]      = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorActive]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ResizeGrip]            = imgui.ImVec4(1.00, 1.00, 1.00, 0.25)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripHovered]     = imgui.ImVec4(1.00, 1.00, 1.00, 0.67)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripActive]      = imgui.ImVec4(1.00, 1.00, 1.00, 0.95)
    imgui.GetStyle().Colors[imgui.Col.Tab]                   = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabHovered]            = imgui.ImVec4(0.28, 0.28, 0.28, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabActive]             = imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocused]          = imgui.ImVec4(0.07, 0.10, 0.15, 0.97)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocusedActive]    = imgui.ImVec4(0.14, 0.26, 0.42, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLines]             = imgui.ImVec4(0.61, 0.61, 0.61, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLinesHovered]      = imgui.ImVec4(1.00, 0.43, 0.35, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogram]         = imgui.ImVec4(0.90, 0.70, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogramHovered]  = imgui.ImVec4(1.00, 0.60, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextSelectedBg]        = imgui.ImVec4(1.00, 0.00, 0.00, 0.35)
    imgui.GetStyle().Colors[imgui.Col.DragDropTarget]        = imgui.ImVec4(1.00, 1.00, 0.00, 0.90)
    imgui.GetStyle().Colors[imgui.Col.NavHighlight]          = imgui.ImVec4(0.26, 0.59, 0.98, 1.00)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingHighlight] = imgui.ImVec4(1.00, 1.00, 1.00, 0.70)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingDimBg]     = imgui.ImVec4(0.80, 0.80, 0.80, 0.20)
    imgui.GetStyle().Colors[imgui.Col.ModalWindowDimBg]      = imgui.ImVec4(0.00, 0.00, 0.00, 0.70)
end

function main() 
    while not isSampAvailable() do wait(0) end
    sampRegisterChatCommand('tg', function ()
        settings.renderWindow = not settings.renderWindow
    end)
    
    if (thisScript().name ~= 'farm_helper_v3.lua') then
        sampShowDialog(333, '������', '{FFFFFF}������ ��� ������������. ������� �������� {FF0000}"farm_helper_v3.lua" {FFFFFF}' ,'�������', _,0)
        thisScript():unload()

    end

    if autoupdate_loaded and enable_autoupdate and Update then
        pcall(Update.check, Update.json_url, Update.prefix, Update.url)
    end

    sampAddChatMessage("{5BCEFA}[AFK-FARM HELPER] {FFFFFF}������� ��������. {5BCEFA}���������: /tg", -1)
    
    while true do
        wait(0)
        if os.date("%H %M") == "5 3" and sampGetGamestate() == 3 then
            bot:sendMessage{chat_id = tonumber(ini.tg.id), text = u8('�� �������� ��������� �����, ���� ����� ������������ ����� 10 ����� (/rec 600)')}
            sampSendChat('/rec 600')
        end
    end

end
