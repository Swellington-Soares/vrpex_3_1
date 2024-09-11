local Config = require 'shared.config'

local vehicleList = {}


local function HasKey(source, plate)
    local playerId = vRP.getPlayerId(vRP.getUserId(source))
    return playerId and vehicleList?[plate]?[playerId]
end

exports('HasKey', HasKey)


function GiveKeys(id, plate)
    lib.print.info('GiveKeys', id, plate)
    local xPlayer = vRP.getPlayerInfo(id)

    lib.print.info(xPlayer.char_id)


    if not xPlayer then return end
    local citizenid = xPlayer.char_id
    if not plate then
        if GetVehiclePedIsIn(GetPlayerPed(id), false) ~= 0 then
            plate = lib.string.strtrim(GetVehicleNumberPlateText(GetVehiclePedIsIn(GetPlayerPed(id), false)))
        else
            return
        end
    end
    if not vehicleList[plate] then vehicleList[plate] = {} end
    vehicleList[plate][citizenid] = true
    vRP.notify(id, locale('notify.vgetkeys'), nil, 5000, 'inform')
    TriggerClientEvent('vehiclekeys:client:AddKeys', id, plate)
end

exports('GiveKeys', GiveKeys)

function RemoveKeys(id, plate)
    local citizenid = vRP.getCharId(id)

    if vehicleList[plate] and vehicleList[plate][citizenid] then
        vehicleList[plate][citizenid] = nil
    end

    TriggerClientEvent('vehiclekeys:client:RemoveKeys', id, plate)
end

exports('RemoveKeys', RemoveKeys)

RegisterNetEvent('vehiclekeys:server:GiveVehicleKeys', function(receiver, plate)
    local giver = source
    if HasKey(giver, plate) then
        vRP.notify(giver, locale('notify.vgkeys'), nil, 5000, 'success')
        if type(receiver) == "table" then
            for _, r in next, receiver or {} do
                GiveKeys(receiver[r], plate)
            end
        else
            GiveKeys(receiver, plate)
        end
    else
        vRP.notify(giver, locale('notify.ydhk'), nil, 5000, 'error')
    end
end)


RegisterNetEvent('vehiclekeys:server:AcquireVehicleKeys', function(plate)
    local src = source
    GiveKeys(src, plate)
end)

RegisterNetEvent('vehiclekeys:server:breakLockpick', function(itemName)
    local src = source
    local xPlayer = vRP.getPlayerInfo(src)   -- QBCore.Functions.GetPlayer(source)
    if not xPlayer then return end
    if not (itemName == 'lockpick' or itemName == 'advancedlockpick') then return end
    exports.ox_inventory:RemoveItem(src, itemName, 1)
end)

RegisterNetEvent('vehiclekeys:server:setVehLockState', function(vehNetId, state)
    SetVehicleDoorsLocked(NetworkGetEntityFromNetworkId(vehNetId), state)
end)

lib.callback.register('vehiclekeys:server:GetVehicleKeys', function(source)
    local src = source
    local xPlayer = vRP.getPlayerInfo(src)   -- QBCore.Functions.GetPlayer(source)
    if not xPlayer then return end
    local citizenid = xPlayer.char_id
    local keysList = {}
    for plate, citizenids in next, vehicleList or {} do
        if citizenids[citizenid] then
            keysList[plate] = true
        end
    end
    return keysList
end)

lib.callback.register('vehiclekeys:server:checkPlayerOwned', function(_, plate)
    return not not vehicleList[plate]
end)

local function lockVehicle(vehicle)
    local model = GetEntityModel(vehicle)
    if Config.NoLockVehicles[model] then return end
    if GetVehicleDoorLockStatus(vehicle) == 0 and not Entity(vehicle).state.owned then
        SetVehicleDoorsLocked(vehicle, 2)
    end
end

AddEventHandler('entityCreated', function(handle)
    pcall(function(entity)
        if DoesEntityExist(entity) and GetEntityType(entity) == 2 then
            lockVehicle(handle)
        end
    end, handle)
end)


CreateThread(function()
    for _, vehicle in next, GetAllVehicles() do
        lockVehicle(vehicle)
    end
    Wait(0)
end)



--#region REGISTER INVENTORY HOOK


--#endregion
