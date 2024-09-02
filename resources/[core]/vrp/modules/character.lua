local ALLOWED_UPDATE_CHARATER_COLUMN <const> = {
    ['firstname'] = true,
    ['lastname'] = true,
    ['registration'] = true,
    ['phone'] = true,
    ['birth_date'] = true,
    ['money'] = true,
    ['datatable'] = true,
    -- ['inventory'] = true
}

local DATE_COLUMN = {
    ['birth_date'] = function (data)
        return os.date('%Y-%m-%d', data // 1000)               
    end 
}


function vRP.createNewCharacter(user_id, firstname, lastname, gender, registration, phone, bithdate, money, inventory, datatable)
    assert(type(money) == "table", 'Money param need be a table like { cash = 0, bank = 0 }')
    assert(type(inventory) == "table",
        'inventory param need be a table like { [1] = { item = \'xxx\', amount = 1, ... } }')
    assert(type(datatable) == "table", 'datatable param need be a tabel')

    money = json.encode(money)
    inventory = json.encode(inventory)
    datatable = json.encode(datatable)

    return vRP.insert('vRP/addPlayer',
        { user_id, firstname, lastname, gender, registration, phone, bithdate, money, inventory, datatable })
end

function vRP.deleteCharacter(char_id)
    vRP.update('vRP/deletePlayer', { char_id })
end

function vRP.updateCharacter(char_id, data)
    local query = 'UPDATE players SET %DATA% WHERE id = ?'
    local _data = {}

    for column, value in next, data do
        if ALLOWED_UPDATE_CHARATER_COLUMN[column] then
            if type(value) == 'table' then
                _data[#_data + 1] = ("`%s` = '%s'"):format(column, json.encode(value))
            elseif type(value) == "boolean" then
                _data[#_data + 1] = '`' .. column .. '` = ' .. (value and 1 or 0)
            elseif type(value) == "string" then
                _data[#_data + 1] = ("`%s` = '%s'"):format(column, value)
            else
                if type(value) == "number" and DATE_COLUMN[column] then                 
                    _data[#_data + 1] = '`' .. column .. '` = ' .. ("'%s'"):format( DATE_COLUMN[column](value) )
                else
                    _data[#_data + 1] = '`' .. column .. '` = ' .. value
                end
            end
        end
    end

    if #_data > 0 then
        local q = table.concat(_data, ', ')
        query = query:gsub('%%DATA%%', q)
        return MySQL.update.await(query, { char_id }) == 1
    end
    return false
end

function vRP.getCharacter(char_id, include_deleted)
    local xPlayer
    if not include_deleted then
        xPlayer = vRP.single('vRP/getPlayer', { char_id })
    else
        xPlayer = vRP.single('vRP/getPlayerIncludeDeleted', { char_id })
    end

    if xPlayer then
        xPlayer.datatable = json.decode(xPlayer.datatable) or {}
        xPlayer.money = json.decode(xPlayer.money) or { wallet = 0, bank = 0}
        xPlayer.inventory = json.decode(xPlayer.inventory) or {}
    end

    return xPlayer
end

function vRP.getAllUserCharacter(user_id, include_deleted)
    local xPlayers
    if not include_deleted then
        xPlayers = vRP.query('vRP/getAllPlayerFromUser', { user_id })
    else
        xPlayers = vRP.query('vRP/getAllPlayerFromUserIncludeDeleted', { user_id })
    end

    for i = 1, #xPlayers or {} do
        xPlayers[i].datatable = json.decode(xPlayers[i].datatable) or {}
        xPlayers[i].money = json.decode(xPlayers[i].money) or {}
        xPlayers[i].inventory = json.decode(xPlayers[i].inventory) or {}
    end

    return xPlayers
end

function vRP.getCharacterBy(column, value)
    local xPlayers = vRP.query('vRP/getPlayersBy', { column, value })
    
    for i = 1, #xPlayers or {} do
        xPlayers[i].datatable = json.decode(xPlayers[i].datatable) or {}
        xPlayers[i].money = json.decode(xPlayers[i].money) or {}
        xPlayers[i].inventory = json.decode(xPlayers[i].inventory) or {}
    end

    return xPlayers
    
end

function vRP.generateRegistrationNumber()
    local registration = ""
    repeat
        registration = lib.string.random('AAA111AA')
        local player = vRP.getCharacterBy("registration", registration)?[1]
    until not player
    return registration
end

function vRP.generateRandomPhoneNumber()
    local phone = ""
    repeat
        phone = lib.string.random('111-111')
        local player = vRP.getCharacterBy("phone", phone)?[1]
    until not player
    return phone
end
