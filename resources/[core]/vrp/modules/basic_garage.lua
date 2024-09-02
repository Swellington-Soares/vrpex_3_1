---@diagnostic disable-next-line: duplicate-set-field
function tvRP.spawnVehicle(model, pos, _type)
    print('model', model, pos, _type)
    local vehicle = CreateVehicleServerSetter(model, _type or 'automobile', pos.x, pos.y, pos.z, pos?.w or 0.0)
    while not DoesEntityExist(vehicle) do Wait(0) end
    return vehicle
end

--proxy
vRP.spawnVehicle = tvRP.spawnVehicle

function vRP.setVehicleGearType(vehicle, gtype)
    if (gtype == 'GEAR_AUTO' or gtype == 0 or gtype == 'GEAR_MANUAL' or gtype == 1) then
        Entity(vehicle).state:set('vrp:garages:setGearType', gtype, true)
    end
end

--tunnel
tvRP.setVehicleGearType = vRP.setVehicleGearType

function vRP.getPlayerVehicleByName(char_id, vehicle)
    return vRP.single('vRP/getPlayerVehicleBy', { 'vehicle', vehicle, char_id })
end

function vRP.isPlayerVehicleSeized(char_id, vehicle)
    return vRP.scalar('vRP/isPlayerVehicleSeized', { char_id, vehicle })
end

function vRP.getAllPlayerVehicles(char_id)
    return vRP.query('vRP/getPlayerVehicleBy', { 'player_id', char_id })
end

function vRP.getPlayerVehicleByPlate(plate)
    return vRP.single('vRP/getPlayerVehicleByPlate', { plate })
end

function vRP.getPlayerVehicleProps(char_id, vehicle)
    return vRP.scalar('vRP/getPlayerVehicleProps', { char_id, vehicle })
end

function vRP.getPlayerVehiclePropsByPlate(plate)
    return vRP.scalar('vRP/getPlayerVehiclePropsByPlate', { plate })
end

function vRP.getPlayerVehicleInGarage(char_id, garageName)
    return vRP.query('vRP/getPlayerVehicleBy', { 'garage', garageName, char_id })
end

function vRP.removeVehicleFromPlayer(char_id, vehicle)
    return vRP.update('vRP/removeVehicleFromPlayer', { vehicle, char_id })
end

function vRP.removePlayerVehicleByPlate(plate)
    return vRP.update('vRP/removeVehicleFromPlayerByPlate', { plate })
end

function vRP.addVehicleToPlayer(char_id, vehicle, plate)
    return vRP.single('vRP/addPlayerVehicle', { vehicle, char_id, plate })
end

function vRP.updatePlayerVehicle(char_id, vehicle, data)
    local ALLOWED_COLUMN_UPDATE = {
        ['seized'] = true,
        ['properties'] = true,
        ['garage'] = true
    }

    local query = 'UPDATE player_vehicles SET #DATA# WHERE vehicle = ? AND player_id = ?'
    local _data = {}
    for column, value in next, data or {} do
        if ALLOWED_COLUMN_UPDATE[column] then
            if type(value) == "table" then
                _data[#_data + 1] = ("`%s` = '%s'"):format(column, json.encode(value))
            elseif type(value) == "boolean" then
                _data[#_data + 1] = ("`%s` = %d"):format(column, value and 1 or 0)
            elseif type(value) == 'string' then
                _data[#_data + 1] = ("`%s` = '%s'"):format(column, value)
            elseif type(value) == 'number' then
                _data[#_data + 1] = ("`%s` = %s"):format(column, tostring(value))
            end
        end
    end

    if #_data > 0 then
        local qq = table.concat(_data, ', ')
        query = query:gsub('#DATA#', qq)
        return MySQL.update.await(query, { vehicle, char_id })
    end

    return false
end

function vRP.transferPlayerVehicleToAnothePlayer(owner_char_id, dest_char_id, vehicle)
    return vRP.scalar("vRP/transferPlayerVehicle", { vehicle, owner_char_id, dest_char_id })
end
