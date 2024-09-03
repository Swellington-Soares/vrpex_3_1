---@diagnostic disable: missing-parameter, deprecated, param-type-mismatch
lib.locale()
local GarageConfig = Config

---@type CZone[]
local garageZones = {}

---@type CZone[]
local houseGarageZones = {}


local function ZoneExists(zoneName)
    for _, zone in next, houseGarageZones do
        if zone?.garageId == zoneName then
            return true
        end
    end
    return false
end

local function CheckPlayers(vehicle)
    for i = -1, 5, 1 do
        local seat = GetPedInVehicleSeat(vehicle, i)
        if seat then
            TaskLeaveVehicle(seat, vehicle, 0)
        end
    end        
end

local function IsVehicleAllowed(classList, vehicle)
    if not GarageConfig.ClassSystem then return true end
    for _, class in ipairs(classList) do
        if GetVehicleClass(vehicle) == class then
            return true
        end
    end
    return false
end

-- RegisterNUICallback('takeOutDepo', function(data, cb)
--     local depotPrice = data.depotPrice
--     if depotPrice ~= 0 then
--         TriggerServerEvent('qb-garages:server:PayDepotPrice', data)
--     else
--         TriggerEvent('qb-garages:client:takeOutGarage', data)
--     end
--     cb('ok')
-- end)

local function OpenGarageMenu(garageId)    
    lib.callback('garages:server:getVehicles', false, function(vehicles)
        local garageInfo = GarageConfig.Garages[garageId]
        if #vehicles > 0 then
            SetNuiFocus(true, true)
            lib.print.info(vehicles)
            SendNUIMessage({
                action = 'VehicleList',
                garageLabel = garageInfo.label,
                vehicles = vehicles,
                baseUrl = GarageConfig.BaseImageUrl
            })
        end
    end, garageId)
end


local function onZoneEnter(self)
    lib.print.info('entered zone', self.id)
    lib.showTextUI(locale('info.car_e'), {
        position = 'bottom-center',

    })
end

local function onZoneExit(self)
    lib.hideTextUI()
end

local function onZoneInside(self)
    if IsControlJustPressed(0, 38) then
        local garage = self.garageId
        local vehicle = GetVehiclePedIsUsing(cache.ped, false)
        if vehicle ~= 0 then
            lib.print.info("Hello")
        else
            OpenGarageMenu(garage)
        end
    end
end

local function CreateGarageBlip(data)
    if not data?.showBlip then return end
    local x, y, z, w = table.unpack(data.takeVehicle)
    local blip = AddBlipForCoord(x, y, z)
    SetBlipSprite(blip, data.blipNumber)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.6)
    SetBlipAsShortRange(blip, true)
    SetBlipColour(blip, data.blipColor)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(data.blipName)
    EndTextCommandSetBlipName(blip)
end

local function CreateZone(garageId, garageInfo, gtype)
    local zone = lib.zones.sphere({
        coords = garageInfo.takeVehicle,
        radius = garageInfo.radius or 5.0,
        debug = true,
        garageId = garageId,
        gtype = garageInfo?.type or gtype,
        inside = onZoneInside,
        onEnter = onZoneEnter,
        onExit = onZoneExit
    })

    if gtype ~= 'house' then
        garageZones[#garageZones + 1] = zone
    else
        houseGarageZones[#houseGarageZones+1] = zone
    end
end

local function DestrouAllZone()
    
    for _, zone in next, garageZones or {} do
        zone:remove()
    end

    for _, zone in next, houseGarageZones or {} do
        zone:remove()
    end

    table.wipe(houseGarageZones)
    table.wipe(garageZones)
end

local function RemoveHouseZone(zoneName)
    for k, zone in next, houseGarageZones or {} do
        if zone.garageId == zoneName and zone.gtype == 'house' then
            zone:remove()
            houseGarageZones[k] = nil
            break
        end
    end
end

local function CreateGarages()
    for id, info in next, GarageConfig.Garages or {} do
        CreateZone(id, info)
        CreateGarageBlip(info)
    end
end


function GetSpawnPoint(garage)
    local location = nil
    if #garage.spawnPoint > 1 then
        local maxTries = #garage.spawnPoint
        for i = 1, maxTries do                        
            local chosenSpawnPoint = garage.spawnPoint[i]
            local isOccupied = IsPositionOccupied(
                chosenSpawnPoint.x,
                chosenSpawnPoint.y,
                chosenSpawnPoint.z,
                5.0,   -- range
                false,
                true,  -- checkVehicles
                false, -- checkPeds
                false,
                false,
                0,
                false
            )
            if not isOccupied then
                location = i --chosenSpawnPoint
                break
            end
        end
    elseif #garage.spawnPoint == 1 then
        location = 1 --garage.spawnPoint[1]
    end
    if not location then
        lib.notify({
           title = garage.label,
           description = locale('error.vehicle_occupied'),
           duratin = 5000,
           position = 'top-right',
           type = 'error'
       })        
    end
    return location
end


local function TrySpawnVehicle(vehicleData)
    lib.print.info(vehicleData)
    local garage = GarageConfig.Garages[vehicleData.garage]
    lib.print.info(garage)
    --verificar se tem vaga
    local spawnPoint = GetSpawnPoint(garage)
    if not spawnPoint then return end
    --verifica se já foi spawnado
    lib.callback('garages:server:isSpawnOk', false, function(isOk)
        if not isOk then 
            return lib.notify({
                title = garage.label,
                description = locale('error.vehicle_occupied'),
                duratin = 5000,
                position = 'top-right',
                type = 'error'
            })
        end

        lib.callback("garages:server:spawnVehicle", false, function(result, message)
            
            if not result then
                return lib.notify({
                    title = garage.label,
                    description = message,
                    duratin = 5000,
                    position = 'top-right',
                    type = 'error'
                })
            end

            lib.notify({
                title = garage.label,
                description = locale('success.vehicle_retired'),
                duratin = 5000,
                position = 'top-right',
                type = 'success'
            })

            local vehicle = NetToVeh( result )

            SetVehicleRadioEnabled(vehicle, false)
            SetVehRadioStation(vehicle, 'OFF')

        end, vehicleData.vehicle, vehicleData.plate, garage, spawnPoint)
    end, vehicleData.plate)
end


local function CloseGarage()
    SendNUIMessage({
        action = 'close'
    })
    SetNuiFocus(false, false)
end


RegisterNUICallback('close', function (_, cb)
    cb('ok')
    CloseGarage()
end)

RegisterNUICallback('spawn', function (body, cb)
    cb('ok')
    CloseGarage()
    TrySpawnVehicle(body)
end)


RegisterNetEvent('garages:client:setHouseGarage', function(house, hasKey) 
    if not house then return end
    local formattedHouseName = string.gsub(string.lower(house), ' ', '')
    local zoneName = 'house_' .. formattedHouseName
    if Config.Garages[formattedHouseName] then
        if hasKey and not ZoneExists(zoneName) then
            CreateZone(formattedHouseName, Config.Garages[formattedHouseName], 'house')
        elseif not hasKey and ZoneExists(zoneName) then
            RemoveHouseZone(zoneName)
        end
    else
       lib.callback('garages:server:getHouseGarage', false, function(garageInfo) -- create garage if not exist
            local garageCoords = garageInfo.garage
            Config.Garages[formattedHouseName] = {
                houseName = house,
                takeVehicle = vector3(garageCoords.x, garageCoords.y, garageCoords.z),
                spawnPoint = {
                    vector4(garageCoords.x, garageCoords.y, garageCoords.z, garageCoords.w or garageCoords.h)
                },
                label = garageInfo.label,
                type = 'house',
                category = Config.VehicleClass['all']
            }
            TriggerServerEvent('garages:server:syncGarage', Config.Garages)
        end, house)
    end
end)


RegisterNetEvent('garages:client:houseGarageConfig', function(houseGarages)
    for _, garageConfig in pairs(houseGarages) do
        local formattedHouseName = string.gsub(string.lower(garageConfig.label), ' ', '')
        if garageConfig.takeVehicle and garageConfig.takeVehicle.x and garageConfig.takeVehicle.y and garageConfig.takeVehicle.z and garageConfig.takeVehicle.w then
            Config.Garages[formattedHouseName] = {
                houseName = garageConfig.name,
                takeVehicle = vector3(garageConfig.takeVehicle.x, garageConfig.takeVehicle.y, garageConfig.takeVehicle.z),
                spawnPoint = {
                    vector4(garageConfig.takeVehicle.x, garageConfig.takeVehicle.y, garageConfig.takeVehicle.z, garageConfig.takeVehicle.w)
                },
                label = garageConfig.label,
                type = 'house',
                category = Config.VehicleClass['all']
            }
        end
    end
    TriggerServerEvent('qb-garages:server:syncGarage', Config.Garages)
end)

RegisterNetEvent('garages:client:addHouseGarage', function(house, garageInfo) -- event from housing on garage creation
    local formattedHouseName = string.gsub(string.lower(house), ' ', '')
    Config.Garages[formattedHouseName] = {
        houseName = house,
        takeVehicle = vector3(garageInfo.takeVehicle.x, garageInfo.takeVehicle.y, garageInfo.takeVehicle.z),
        spawnPoint = {
            vector4(garageInfo.takeVehicle.x, garageInfo.takeVehicle.y, garageInfo.takeVehicle.z, garageInfo.takeVehicle.w)
        },
        label = garageInfo.label,
        type = 'house',
        category = Config.VehicleClass['all']
    }
    TriggerServerEvent('qb-garages:server:syncGarage', Config.Garages)
end)

RegisterNetEvent('garages:client:removeHouseGarage', function(house)
    Config.Garages[house] = nil
end)


local garageInfo = {
    id = 'pillboxgarage',
    label = 'Pillbox Garage Parking',
    takeVehicle = vector3(213.2, -796.05, 30.86),
    spawnPoint = {
        vector4(222.02, -804.19, 30.26, 248.19),
        vector4(223.93, -799.11, 30.25, 248.53),
        vector4(226.46, -794.33, 30.24, 248.29),
        vector4(232.33, -807.97, 30.02, 69.17),
        vector4(234.42, -802.76, 30.04, 67.2)
    },
    showBlip = true,
    blipName = 'Public Parking',
    blipNumber = 357,
    blipColor = 3,
    type = 'public',
    category = Config.VehicleClass['car']
}


RegisterCommand('tg', function(source, args, raw)
    lib.callback('garages:server:getVehicles', false, function(vehicles)
        lib.print.info(vehicles)
    end, garageInfo.id)
end)


RegisterCommand('sv', function(source, args, raw)
    lib.callback("garages:server:spawnVehicle", false, function(result, message)
        lib.print.info(result)
    end, 'brioso', '000AAA11', garageInfo, 1)
end)

AddEventHandler('onResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    CreateGarages()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        DestrouAllZone()
    end
end)
