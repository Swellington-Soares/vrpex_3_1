local Proxy = require('@vrp.lib.Proxy')
local vRP = Proxy.getInterface('vRP')
local vRPConfig = require('@vrp.cfg.base')

local players = {}
local firstcreation = {}

local function GiveInitialItems(source)
    if vRPConfig?.initial_items then
        local user_id = vRP.getUserId( source )
        for item, amount in next, vRPConfig?.initial_items or {} do            
            if item == 'phone' then
                local phoneNumber = vRP.getPlayerTable(user_id)?.phone
                if phoneNumber then
                    pcall(
                        function()
                            return exports.ox_inventory:AddItem(source, item, 1, {
                                number = phoneNumber,
                                description = 'Número: ' .. phoneNumber
                            })
                        end)
                end
            else
                pcall(function()
                    return exports.ox_inventory:AddItem(source, item, amount)
                end)
            end
        end
    end
end

lib.callback.register('multichar:server:requestCharsInfo', function(source)
    local user_id = vRP.getUserId(source)
    if not user_id then
        -- return DropPlayer(source, locale('retry_character_error'))
        return
    end
    local characters = vRP.getAllUserCharacter(user_id, true)
    local _characters = {}
    for _, info in next, characters or {} do        
        _characters[#_characters + 1] = {
            user_id = user_id,
            id = info.id,
            firstname = info.firstname,
            lastname = info.lastname,
            registration = info.registration,
            phone = info.phone,
            birth_date = info.birth_date,    
            skin = info.skin,        
    -- tattoos = tattoos,
            last_location = info?.datatable?.position or nil,
            inside = info?.datatable?.inside or nil,
            deleted = info?.deleted_at ~= nil
        }
    end
    -- vRP.setPlayerBucket(source, source + 1, false)
    local max_chars = tonumber(vRP.getUData(user_id, 'vrp:max_char') or 1) or 1    
    return 4, _characters
end)


lib.callback.register("multichar:server:createchar", function(source, firstname, lastname, date, gender)
    local user_id = vRP.getUserId(source)
    if not user_id then
        return print('DROP')
    end

    local currentDate = os.date("*t")
    local birthDate = os.date("*t", date // 1000)

    if currentDate.year - birthDate.year < 18 then
        return false, locale('player_need_be_18_more')
    end

    if not firstname or not firstname:match("^[%aÀ-ÖØ-öø-ÿ]+$") then
        return false, locale('firstname_invalid')
    end

    if not lastname or not lastname:match("^[%aÀ-ÖØ-öø-ÿ]+$") then
        return false, locale('lastname_invalid')
    end

    --dat itens iniciais
    local char_id = vRP.createPlayer(
        user_id,
        firstname,
        lastname,
        gender or 'M',
        ("%d-%d-%s"):format(birthDate.year, birthDate.month,
            birthDate.day < 10 and ('0' .. birthDate.day) or tostring(birthDate.day))
    )

    local logged = vRP.login(source, user_id, char_id, true)

    repeat
        Wait(1000)
    until firstcreation[source]

    -- vRP.setPlayerBucket(source, 0, false)


    pcall(function()
        return exports.ox_inventory:AddItem(source, 'id_card', 1, {
            label = ("%s %s"):format(firstname, lastname),
            description = ('Data de Nascimento: %s\nSexo: %s\n'):format(os.date("%d/%m/%Y", date // 1000), gender)
        })
    end)
    GiveInitialItems(source)    
    return logged, "Personagem criado com sucesso.", char_id
end)


lib.callback.register("multichar:server:login", function(source, char_id)
    if vRP.login(source, vRP.getUserId(source), char_id, false) then
        local xPlayer = vRP.getPlayerInfo(source)
        local pos = xPlayer.datatable?.position
        
        if not players[xPlayer.id] then
            players[xPlayer.id] = true
            return true
        else
            return true, { pos = pos, home = xPlayer.datatable.inside }
        end        
    end
    DropPlayer(source, 'Failed to Login...')
    return false
end)


AddEventHandler('vrp:login', function(source, user_id, char_id, created)
    Wait(1000)
    firstcreation[source] = true    
end)

lib.callback.register('multichar:server:deleteChar', function(source, charId)
    local user_id = vRP.getUserId( source )
    if not user_id then return false end
    MySQL.update.await('UPDATE players SET deleted_at = NOW() where id = ? AND user_id = ?', { charId, user_id })
    return true
end)