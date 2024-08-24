lib.locale()

local config = lib.load('config')
local Proxy = require ('@vrp.lib.Proxy')
local vRP = Proxy.getInterface('vRP')

local players = {}
local firstcreation = {}

lib.callback.register('multichar:server:getCharacters', function(source)
    local user_id = vRP.getUserId(source)
    if not user_id then
        return DropPlayer(source, locale('retry_character_error'))
    end
    local characters = vRP.getAllUserCharacter(user_id, false)
    local _characters = {}
    for _, info in next, characters or {} do
        local custom = json.decode(vRP.getPlayerData(info.id, 'player:custom') or '{}') or {}
        local tattoos = json.decode(vRP.getPlayerData(info.id, 'player:tattoo') or '{}') or {}        
        _characters[#_characters + 1] = {
            user_id = user_id,
            id = info.id,
            firstname = info.firstname,
            lastname = info.lastname,
            registration = info.registration,
            phone = info.phone,
            birth_date = info.birth_date,
            custom = custom,
            tattoos = tattoos,
            last_location = info?.datatable?.position or nil
        }
    end
    vRP.setPlayerBucket(source, source + 1, false)
    return _characters
end)


lib.callback.register("multichar:server:createchar", function(source, firstname, lastname, date)
    local user_id = vRP.getUserId(source)
    if not user_id then
        return print('DROP')
    end

    local currentDate = os.date("*t")
    local birthDate = os.date("*t", date // 1000)


    print(birthDate.year, currentDate.year, firstname, lastname)

    if currentDate.year - birthDate.year < 18 then
        return false, locale('player_need_be_18_more')
    end

    if not firstname or firstname:match("[^%a]") then
        return false, locale('firstname_invalid')
    end

    if not lastname or lastname:match("[^%a]") then
        return false, locale('lastname_invalid')
    end

    --dat itens iniciais
    local char_id = vRP.createPlayer(
        user_id,
        firstname,
        lastname,
        ("%d-%d-%s"):format(birthDate.year, birthDate.month,
            birthDate.day < 10 and ('0' .. birthDate.day) or tostring(birthDate.day))
    )

    local logged = vRP.login(source, user_id, char_id, true)

    repeat
        Wait(1000)
    until firstcreation[source]

    vRP.setPlayerBucket(source, 0, false)

    print(user_id, char_id)

    return logged, "Personagem criado com sucesso.", char_id
end)


lib.callback.register("multichar:server:login", function(source, char_id)
    if vRP.login(source, vRP.getUserId(source), char_id, false) then
        vRP.setPlayerBucket(source, 0, false)
        return true
    end
    return false
end)


AddEventHandler('vrp:login', function(source, user_id, char_id, created)
    if not players[source] then players[source] = {} end
    if not players[source][user_id] then players[source][user_id] = {} end
    local isFirst = not players[source][user_id][char_id]
    players[source][user_id][char_id] = true
    if not created then
        TriggerClientEvent('multichar:client:login', source, user_id, char_id)
    else
        firstcreation[source] = true
    end
end)
