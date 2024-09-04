lib.locale()
lib.require('@vrp.lib.utils')
local Proxy = require('@vrp.lib.Proxy')
local VehicleListAPI = lib.require('@vrp.lib.vehicles')
local vRP = Proxy.getInterface('vRP')
local GarageConfig = Config

--#region VARIABLES
local OutsideVehicles = {}
local command_lock = {}

--#endregion

local function filterVehicleTable(vehicles, category)
    local filtered = {}
    for _, vehicle in next, vehicles or {} do
        if lib.table.contains(category, vehicle.classId) then
            filtered[#filtered + 1] = vehicle
        end
    end
    return filtered
end

lib.callback.register('garages:server:isSpawnOk', function (_, plate)
    return not ( OutsideVehicles[plate] and DoesEntityExist( OutsideVehicles[plate].entity ))
end)


lib.callback.register('garages:server:depotVehicle', function (source, vehNet, plate, class, garageId, props)
    if command_lock[ source ] then return false end
    command_lock[ source ] = true
    local user_id = vRP.getUserId( source )
    local char_id = vRP.getPlayerTable( user_id )?.id
    if not ( user_id and char_id ) then return false, locale('error.no_user') end
    local vehicle = NetworkGetEntityFromNetworkId(vehNet)


    if Entity(vehicle).state?.is_service then

        if OutsideVehicles[plate] then
            OutsideVehicles[plate] = nil        
        end

        SetTimeout(2000, function ()
            DeleteEntity( vehicle )
        end)

        return true
    end

    
    local garageInfo = GarageConfig.Garages[garageId]
    if garageInfo?.category and not table.contains(garageInfo?.category, class) then
        return false, locale('error.not_correct_type')
    end

    local ownerId = Entity(vehicle).state?.owner
    if ownerId and ownerId ~= source then return false, locale('error.not_owned') end

    
    
    if GarageConfig.Garages[garageId]?.type == 'house' then 
        local houseId = string.gsub(garageId, 'house_', '')
        if not exports['ps-housing']:IsOwner(source, houseId) then
            return false, locale('error.not_correct_type')
        end
    end

    if OutsideVehicles[plate] then
        OutsideVehicles[plate] = nil        
    end

    MySQL.update.await('UPDATE player_vehicles SET properties=?, garage=? WHERE plate = ?', { json.encode(props or {}), garageId, plate })

    SetTimeout(2000, function ()
        DeleteEntity(vehicle)
    end)

    command_lock[ source ] = nil

    return true
end)


lib.callback.register('garages:server:getVehicles', function(source, garageId)
    local user_id = vRP.getUserId(source)
    if not user_id then 
        return false,  locale('error.no_user')
    end
    local charId = vRP.getPlayerId(user_id)

    if not charId then
        return false,  locale('error.no_user')
    end

    local vehicles

    local garageInfo = GarageConfig.Garages[garageId]
    
    if not garageInfo then return false, locale('error.no_garage') end
    if garageInfo?.type ~= 'service' then
        if garageInfo?.type ~= 'depot' then
            if not GarageConfig.SharedGarages  then
                vehicles = MySQL.query.await(
                    'SELECT vehicle, properties, seized, plate, garage, created_at FROM player_vehicles WHERE player_id = ? AND garage = ?',
                    { charId, garageId })
            else
                vehicles = MySQL.query.await(
                'SELECT vehicle, properties, seized, plate, created_at FROM player_vehicles WHERE player_id = ?',
                    { charId })
            end
        else
            vehicles = MySQL.query.await(
                'SELECT vehicle, properties, seized, plate, garage, created_at FROM player_vehicles WHERE player_id = ? AND garage = ? and seized == 1',
                { charId, garageInfo.id })
        end
    elseif garageInfo?.type == 'service' and GarageConfig.ServiceGarages[garageInfo?.id] then
        vehicles = {}
        for veh in next, GarageConfig.ServiceGarages[garageInfo?.id] do
            local vehicleInfo = VehicleListAPI:GetVehicleInfoByModel(veh)
            if vehicleInfo then
                vehicles[#vehicles + 1] = {
                    created_at = os.date('%d/%m/%Y'),
                    fuel = 100.0,
                    engine = 1000.0,
                    body = 1000.0,
                    classId = vehicleInfo.classId,
                    manufacturer = vehicleInfo.manufacturer,
                    displayName = vehicleInfo.displayName
                }
            end
        end
    end

    if not vehicles or #vehicles == 0 then return false, locale('error.no_vehicles') end

    for k, data in next, vehicles do
        local vehicleInfo = VehicleListAPI:GetVehicleInfoByModel(data.vehicle)
        if vehicleInfo then
            vehicles[k] = data
            vehicles[k].created_at = os.date('%d/%m/%Y', vehicles[k].created_at // 1000)
            vehicles[k].fuel = vehicles[k]?.properties?.fuel or 100.0
            vehicles[k].engine = vehicles[k]?.properties?.engine or 1000.0
            vehicles[k].body = vehicles[k]?.properties?.body or 1000.0
            vehicles[k].properties = nil
            vehicles[k].classId = vehicleInfo.classId
            vehicles[k].manufacturer = vehicleInfo.manufacturer
            vehicles[k].displayName = vehicleInfo.displayName
        end
    end

    if GarageConfig.ClassSystem and garageInfo?.category and #garageInfo.category > 0 and not lib.table.contains(garageInfo.category, 'all') then
        return filterVehicleTable(vehicles, garageInfo.category)
    end

    return vehicles
end)

lib.callback.register('garages:server:spawnVehicle', function(source, vehicleName, plate, garageInfo, vagacy)
    local user_id = vRP.getUserId(source)
    if not user_id then return false, locale('identity_id_fail') end
    local playerId = vRP.getPlayerId(user_id)
    if not playerId then return false, locale('identity_id_fail') end
    local vehicle
    if garageInfo?.type ~= 'services' then
        vehicle = MySQL.single.await(
        'SELECT plate, properties, gear_type FROM player_vehicles WHERE player_id = ? AND vehicle = LOWER(?) and plate = UPPER(?)',
            { playerId, vehicleName, plate })

        if vehicle then
            vehicle.properties = json.decode(vehicle.properties) or {}
            vehicle.properties.plate = plate
        end
        
    elseif garageInfo?.type == 'service' then
        if GarageConfig.ServiceGarages[garageInfo?.id][vehicleName] then
            vehicle = {
                vehicle = vehicleName,
                ---@type VehicleProperties
                properties = GarageConfig.ServiceGarages[garageInfo?.id][vehicleName]?.props or {}
            }            
            vehicle.properties.bodyHealth = 1000
            vehicle.properties.engineHealth = 1000
            vehicle.properties.fuelLevel = 100            
        end
    end
    if not vehicle then return false, locale('vehicle_find_fail') end
    local vehicleEntity = vRP.spawnVehicle(vehicleName, garageInfo.spawnPoint[vagacy])    
    if garageInfo?.type == 'service' then
        Entity(vehicleEntity).state:set('is_service', true, true)                
    end
    Entity(vehicleEntity).state:set('owner', source, true)
    lib.setVehicleProperties(vehicleEntity, vehicle.properties)
    if vehicle?.gear_type then
        vRP.setVehicleGearType( vehicleEntity, vehicle.gear_type )
    end
    if not plate then
        plate = GetVehicleNumberPlateText( vehicleEntity )
    end
    if plate then
        SetVehicleNumberPlateText( vehicleEntity, plate )
    end
    local netId = NetworkGetNetworkIdFromEntity(vehicleEntity)
    OutsideVehicles[plate] = { netId = netId, entity = vehicleEntity, owner = source, model = vehicleName }

    return netId
end)

RegisterNetEvent('garages:server:UpdateOutsideVehicle', function(plate, vehicleNetID)
    OutsideVehicles[plate] = {
        netID = vehicleNetID,
        entity = NetworkGetEntityFromNetworkId(vehicleNetID)
    }
end)


RegisterNetEvent('garages:server:syncGarage', function(updatedGarages)
    GarageConfig.Garages = updatedGarages
end)
