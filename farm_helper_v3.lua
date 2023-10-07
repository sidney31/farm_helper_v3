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

local Telegram = require('dolbogram')
local bot = Telegram('5891391707:AAEHRP2JRSA0ALD5r3JG8v3-v5IRhvmQF_k')
local ChatId = 976221897
local encoding = require('encoding')
encoding.default = 'CP1251'
local u8 = encoding.UTF8

local effil = require("effil")
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

    main = {
        joinNotif = true,
        beforePd = true,
        min = 3,
        pd = true,
        hungry = true,
        autoeat = true,
        method = 1,
        userId = 0,
    },

    boxes = {
        box = true,
        dbox = true,
        pbox = true,
        tmask = true,
        tls = true,
    },

    stats ={
        sdonate = true,
        shp = true,
        ssat = true,
        slvl = true,
        sexp = true,
        smoney = true,
        sbank = true,
        sdep = true,
    },

    payday = {
        payday = true,
        bank = true,
        depplus = true,
        depall = true,
        lvlexp = true,
    },

    logs = {
        tags = '',
        buysellN = true,
        damageN = true,
    },
}, directIni))
inicfg.save(ini, directIni)


local settings = {
    renderWindow = false,
    tgWindow = new.bool(),
    checkbox = new.bool(),
    joinNotif = new.bool(),
    beforePd = new.bool(),
    min = new.int(0),
    pd = new.bool(),
    hungry = new.bool(),
    autoeat = new.bool(),
    method = new.int(0),
    box = new.bool(),
    dbox = new.bool(),
    pbox = new.bool(),
    tmask = new.bool(),
    tls = new.bool(),
    token = new.char[256](u8:decode(ini.tg.token)),
    tags = new.char[256](str(ini.logs.tags)),
    ttags = new.char[256](),
    id = new.char[256](u8:decode(ini.tg.id)),
    sdonate = new.bool(),
    shp = new.bool(),
    ssat = new.bool(),
    slvl = new.bool(),
    sexp = new.bool(),
    smoney = new.bool(),
    sbank = new.bool(),
    sdep = new.bool(),
    payday = new.bool(),
    bank = new.bool(),
    depplus = new.bool(),
    depall = new.bool(),
    lvlexp = new.bool(),
    buysellN = new.bool(),
    damageN = new.bool(),
    userId = new.int(0),
}

local az = ''
local hp = ''
local lvl = ''
local exp = ''
local money = ''
local bank = ''
local deposite = ''
local satiety = ''
local sNotif ='-����������-\n'

local n_deppd = ''
local n_alldeppd = ''
local n_bankpd = ''
local n_allbankpd = ''
local n_lvl, n_exp = '', ''
local pdNotif = '-PayDay-'

local eat = true
local out = ''
local payday = false
local stats = false

local roulettes = false
local box, boxtime = 0, 0
local dbox, dboxtime = 0, 0
local pbox, pboxtime = 0, 0
local tmask, tmasktime = 0, 0
local tls, tlstime = 0, 0
local use = 0
local close = 0
local userId = 0
local wbook = false;

function msg(...) sampAddChatMessage(table.concat({...}, '  '), -1) end

bot:connect()

bot:on('message', function(message)
    if message.text == '/start' then
        bot:sendMessage{chat_id = ChatId, text = u8('���������� ��������'), reply_markup = {
            keyboard = {
                { { text = u8('������� �������') }, {text=u8('����� � �����������')} },
                { { text = u8('����������') }, { text = u8('�������� � ��������') } },
            }
        }}
    elseif message.text == u8('������� �������') then
        openKeys()
    elseif message.text == u8('����������') then
        getStats()
    elseif message.text == u8('�������� � ��������') then
        bot:sendMessage{chat_id = ChatId, text = u8('��� ������ �������?'), reply_markup = {
            inline_keyboard = {
                { { text = u8('���������'), callback_data = 'rec' }, { text = u8('�����'), callback_data = 'quit' } },
            }
        }}
    elseif message.text == u8('����� � �����������') then
        checkHoursInOrganization()
    else
        bot:sendMessage{chat_id = ChatId, text = u8('����������� �������')}
    end
end)

bot:on('callback_query', function(query)
    if query.data == 'rec' then
        sampSendChat('/rec')
        bot:sendMessage{chat_id = ChatId, text = u8('�������� ���������')}
    elseif query.data == 'quit' then
        sampProcessChatInput('/q')
        bot:sendMessage{chat_id = ChatId, text = u8('���� �������')}
    end
end)

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
    sampAddChatMessage('invent', -1)
    wait(500)
    if ini.boxes.box then
        sampSendClickTextdraw(box)
        wait(500)
        sampSendClickTextdraw(use + 1)
    end
    wait(500)
    if ini.boxes.pbox then
        sampSendClickTextdraw(pbox)
        wait(500)
        sampSendClickTextdraw(use + 1)
    end
    wait(500)
    if ini.boxes.dbox then
        sampSendClickTextdraw(dbox)
        wait(500)
        sampSendClickTextdraw(use + 1)
    end
    wait(500)
    if ini.boxes.tmask then
        sampSendClickTextdraw(tmask)
        wait(500)
        sampSendClickTextdraw(use + 1)
    end
    wait(500)
    if ini.boxes.tls then
        sampSendClickTextdraw(tls)
        wait(500)
        sampSendClickTextdraw(use + 1)
    end
    wait(500)
    sampSendClickTextdraw(close)
    wait(500)
    roulettes = false
end

function getStats()
    sampSendChat('/stats')
    stats = true
end

function checkHoursInOrganization()
    sampSendChat('/wbook')
    wbook = true;
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
            bot:sendMessage{chat_id = ChatId, text = u8('�� �������� ������� �������� ' .. boxtime .. ' �����.')}
        end
        if data.text:find('(%d+) min') and ini.boxes.dbox and id == tonumber(dbox) + 1 then
            dboxtime = data.text:match('(%d+)') 
            bot:sendMessage{chat_id = ChatId, text = u8('�� �������� ��������� ������� �������� ' .. dboxtime .. ' �����.')}
        end
        if data.text:find('(%d+) min') and ini.boxes.pbox and id == tonumber(pbox) + 1 then
            pboxtime = data.text:match('(%d+)') 
            bot:sendMessage{chat_id = ChatId, text = u8('�� �������� ����������� ������� �������� ' .. pboxtime .. ' �����.')}
        end
        if data.text:find('(%d+) min') and ini.boxes.tmask and id == tonumber(tmask) + 1 then
            tmasktime = data.text:match('(%d+)') 
            bot:sendMessage{chat_id = ChatId, text = u8('�� �������� ������� ����� ����� �������� ' .. tmasktime .. ' �����.')}
        end
        if data.text:find('(%d+) min') and ini.boxes.tls and id == tonumber(tls) + 1 then
            tlstime = data.text:match('(%d+)') 
            bot:sendMessage{chat_id = ChatId, text = u8('�� �������� ������� ���-������ �������� ' .. tlstime .. ' �����.')}
        end
    end

    -------------------------------------------����� ��������-------------------------------------------
    if id == 2049 then
        bot:sendMessage{
            chat_id = ChatId,
            text = u8(data.text)
        }
    end
end

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
    sampAddChatMessage(dialogId, -1)
    
    if dialogId == 32 and roulettes then
        sampSendDialogResponse(dialogId, 0, -1, -1)
        lua_thread.create(function ()
            wait(200)
            sampCloseCurrentDialogWithButton(0)
        end)
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
            if line:find('������: %{......%}%[($%d+)%]') then
                money = line:match('������: %{......%}%[($%d+)%]')
                sNotif = sNotif..'\n������ �� �����: '..separator(money)
            end
            if line:find('������ � �����: %{......%}%[($%d+)%]') then
                bank = line:match('������ � �����: %{......%}%[($%d+)%]')
                sNotif = sNotif..'\n������ � �����: '..separator(bank)
            end
            if line:find('������ �� ��������: %{......%}%[($%d+)%]') then
                deposite = line:match('������ �� ��������: %{......%}%[($%d+)%]')
                sNotif = sNotif..'\n������� ����: '..separator(deposite)
            end
        end
        --return false
    end
    if stats then
        stats = false
        bot:sendMessage{chat_id = ChatId, text = u8(sNotif)}
        lua_thread.create(function ()
            wait(500)
            sampCloseCurrentDialogWithButton(0)
        end)
    end

    if dialogId == 0 and text:find('�����!') then
        sampSendDialogResponse(0, 1, 0, -1)
        return false
    end

    if dialogId == 25228 and wbook then
        sampSendDialogResponse(dialogId, 1, 0, -1)
    end
    if dialogId == 25627 and wbook then
        if text:find('(%d+) �����') then
            local hours = text:match('(%d+) �����')
            bot:sendMessage{chat_id = ChatId, text = u8('�� ������� �������� '..hours..' �����')}
        end
        wbook = false
        lua_thread.create(function ()
            wait(500)
            sampCloseCurrentDialogWithButton(0)
            wait(500)
            sampCloseCurrentDialogWithButton(0)
        end)
    end
end

function sampev.onServerMessage(color, text)
    if text:find('����� ���������� �� Arizona Role Play!')  then
        bot:sendMessage{chat_id = ChatId, text = u8('�� �������������� � �������!')}
    end
    if text:find('_____���������� ���_____') then
        pdNotif = '-PayDay-'
        lua_thread.create(function()
            wait(2000)
            bot:sendMessage{chat_id = ChatId, text = u8(pdNotif)}
        end)
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
    end
    if text:find('�� �������� ������ %d+ ����� ��� ���!') then
        sendTelegramNotification('������ �� ��� �������, '..text)
    end

    if roulettes then
        if text:find('�� ������������ ������ � ��������� � �������� (.*)!') then
            out = text:match('�� ������������ ������ � ��������� � �������� (.*)!')
             bot:sendMessage{chat_id = ChatId, text = u8('������ ������ � ���������. �������� ' .. out .. '.')}
        end
        if text:find('�� ������������ ���������� ������ � ��������� � �������� (.*)!') then
            out = text:match('�� ������������ ���������� ������ � ��������� � �������� (.*)!')
             bot:sendMessage{chat_id = ChatId, text = u8('������ ���������� ������ � ���������. �������� ' .. out .. '.')}
        end
        if text:find('�� ������������ ������ ����� ����� � �������� (.*)!') then
            out = text:match('�� ������������ ������ ����� ����� � �������� (.*)!')
             bot:sendMessage{chat_id = ChatId, text = u8('������ ������ ����� �����. ������� ' .. out .. '.')}
        end
        if text:find('�� ������������ ������ ��� ������� � �������� (.*)!') then
            out = text:match('�� ������������ ������ ��� ������� � �������� (.*)!')
             bot:sendMessage{chat_id = ChatId, text = u8('������ ������ ��� �������. ������� ' .. out .. '.')}
        end
    end
    if text:find('�� ������ (.+) %((%d+) ��%.%) � ������ (%w+_%w+) �� $(%d+)') then
        local item, lot, name, sum = text:match('�� ������ (.+) %((%d+) ��%.%) � ������ (%w+_%w+) �� $(%d+)')
        local text = name .. ' ������ ' .. lot .. ' ' .. item .. ', �� �����: $' .. separator(tostring(sum))
        bot:sendMessage{chat_id = ChatId, text = u8(text)}
    end

    if text:find('(%w+_%w+) ����� � ��� (.+) %((%d+) ��%.%), �� �������� $(%d+) �� ������� %(�������� %d* �������%(�%)%)') then
        local name, item, lot, sum = text:match('(%w+_%w+) ����� � ��� (.+) %((%d+) ��%.%), �� �������� $(%d+) �� ������� %(�������� %d* �������%(�%)%)')
        local text = name .. ' ����� ' .. lot .. ' ' .. item .. ', �� �����: $' .. separator(tostring(sum))
        bot:sendMessage{chat_id = ChatId, text = u8(text)}
    end
end

-- function sampGetGunNameById(arg)
--     --TODO: ����������
--     if arg == 0 then return '������'
--     elseif arg == 1 then return '�������'
--     elseif arg == 2 then return '������ ��� ������'
--     elseif arg == 3 then return '����������� �������'
--     elseif arg == 4 then return '����'
--     elseif arg == 5 then return '����������� ����'
--     elseif arg == 6 then return '������'
--     elseif arg == 7 then return '���'
--     elseif arg == 8 then return '������'
--     elseif arg == 10 or arg == 11 then return '�����'
--     elseif arg == 12 or arg == 13 then return '���������'
--     elseif arg == 14 then return '������ ������'
--     elseif arg == 15 then return '������'
--     elseif arg == 16 then return '�������'
--     elseif arg == 17 then return '������������� ����'
--     elseif arg == 18 then return '�������� ��������'
--     elseif arg == 22 then return '��������� 9��'
--     elseif arg == 23 then return '��������� 9�� � ����������'
--     elseif arg == 24 then return '��������� Desert Eagle'
--     elseif arg == 25 then return '���������'
--     elseif arg == 26 then return '������'
--     elseif arg == 27 then return '��������������� ���������'
--     elseif arg == 28 then return '���'
--     elseif arg == 29 then return 'MP5'
--     elseif arg == 30 then return '�������� �����������'
--     elseif arg == 31 then return '�������� �4'
--     elseif arg == 32 then return '�������� Rifle'
--     elseif arg == 33 then return '����������� ��������'
--     elseif arg == 35 then return '���'
--     elseif arg == 36 then return '��������������� ������'
--     elseif arg == 37 then return '�������'
--     elseif arg == 38 then return '��������'
--     elseif arg == 39 then return '������'
--     elseif arg == 40 then return '����� � ��������'
--     elseif arg == 41 then return '���������� ������'
--     elseif arg == 42 then return '������������'
--     elseif arg == 43 then return '������'
--     elseif arg == 44 then return '������'
--     elseif arg == 45 then return '������'
--     elseif arg == 46 then return '������'
--     else return false
--     end
-- end

function save()
    ini.tg.id = u8:decode(str(settings.id))
    ini.tg.token = u8:decode(str(settings.token))
    ini.main.joinNotif = settings.joinNotif[0]
    ini.main.beforePd = settings.beforePd[0]
    ini.main.min = settings.min[0]
    ini.main.pd = settings.pd[0]
    ini.main.hungry = settings.hungry[0]
    ini.main.autoeat = settings.autoeat[0]
    ini.main.method = settings.method[0]
    ini.boxes.box = settings.box[0]
    ini.boxes.dbox = settings.dbox[0]
    ini.boxes.pbox = settings.pbox[0]
    ini.boxes.tmask = settings.tmask[0]
    ini.boxes.tls = settings.tls[0]
    ini.stats.sdonate = settings.sdonate[0]
    ini.stats.shp = settings.shp[0]
    ini.stats.ssat = settings.ssat[0]
    ini.stats.slvl = settings.slvl[0]
    ini.stats.sexp = settings.sexp[0]
    ini.stats.smoney = settings.smoney[0]
    ini.stats.sbank = settings.sbank[0]
    ini.stats.sdep = settings.sdep[0]
    ini.payday.payday = settings.payday[0]
    ini.payday.bank = settings.bank[0]
    ini.payday.depplus = settings.depplus[0]
    ini.payday.depall = settings.depall[0]
    ini.payday.lvlexp = settings.lvlexp[0]
    ini.logs.tags = str(settings.tags)
    ini.logs.buysellN = settings.buysellN[0]
    ini.logs.damageN = settings.damageN[0]
    inicfg.save(ini, directIni)
end

function main()
    while not isSampAvailable() do wait(0) end
    wait(0)
    
    settings.joinNotif[0] = ini.main.joinNotif
    settings.beforePd[0] = ini.main.beforePd
    settings.min[0] = ini.main.min
    settings.pd[0] = ini.main.pd
    settings.hungry[0] = ini.main.hungry
    settings.autoeat[0] = ini.main.autoeat
    settings.method[0] = ini.main.method
    settings.box[0] = ini.boxes.box
    settings.dbox[0] = ini.boxes.dbox
    settings.pbox[0] = ini.boxes.pbox
    settings.tmask[0] = ini.boxes.tmask
    settings.tls[0] = ini.boxes.tls
    settings.sdonate[0] = ini.stats.sdonate
    settings.shp[0] = ini.stats.shp
    settings.ssat[0] = ini.stats.ssat
    settings.sexp[0] = ini.stats.sexp
    settings.slvl[0] = ini.stats.slvl
    settings.smoney[0] = ini.stats.smoney
    settings.sbank[0] = ini.stats.sbank
    settings.sdep[0] = ini.stats.sdep
    settings.payday[0] = ini.payday.payday
    settings.bank[0] = ini.payday.bank
    settings.depplus[0] = ini.payday.depplus
    settings.depall[0] = ini.payday.depall
    settings.lvlexp[0] = ini.payday.lvlexp
    settings.buysellN[0] = ini.logs.buysellN
    settings.damageN[0] = ini.logs.damageN

    -- check_health()
end
