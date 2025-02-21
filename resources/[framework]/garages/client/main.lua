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
    
    lib.callback('garages:server:getVehicles', false, function(vehicles, errorMessage)
     
        local garageInfo = GarageConfig.Garages[garageId]
        if vehicles and type(vehicles) == "table" and #vehicles > 0 then
            SetNuiFocus(true, true)
    
            SendNUIMessage({
                action = 'VehicleList',
                garageLabel = garageInfo.label,
                vehicles = vehicles,
                baseUrl = GarageConfig.BaseImageUrl
            })
        else
            lib.notify({
                position = 'top-right',
                title = locale('info.title'),
                description = errorMessage,
                type = 'error',
                duration = 5000,
                showDuration = true
            })
        end
    end, garageId)
end


local function onZoneEnter(self)
    
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
        local vehicle = GetVehiclePedIsIn(cache.ped, false)
        if vehicle ~= 0 then
            lib.callback('garages:server:depotVehicle', false, function(result, errorMessage)
                if result then
                    CheckPlayers(vehicle)
                elseif errorMessage then
                    lib.notify({
                        title = GarageConfig.Garages[self.garageId]?.label or locale('info.title'),
                        description = errorMessage,
                        type = 'error',
                        duration = 3000,
                        showDuration = true,
                        position = 'top-right'
                    })
                end
            end, VehToNet(vehicle), GetVehicleNumberPlateText(vehicle), GetVehicleClass(vehicle), self.garageId,
                Entity(vehicle).state?.owner and lib.getVehicleProperties(vehicle) or false)
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
        debug = false,
        garageId = garageId,
        gtype = garageInfo?.type or gtype,
        inside = onZoneInside,
        onEnter = onZoneEnter,
        onExit = onZoneExit
    })

    if gtype ~= 'house' then
        garageZones[#garageZones + 1] = zone
    else
        houseGarageZones[#houseGarageZones + 1] = zone
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
    CreateThread(function()
        if #garageZones ~= 0 then return end
        for id, info in next, GarageConfig.Garages or {} do
            CreateZone(id, info)
            CreateGarageBlip(info)
        end

        Wait(0)
    end)
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
    
    local garage = GarageConfig.Garages[vehicleData.garage]
    
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
            while not NetworkDoesEntityExistWithNetworkId(result) do Wait(0) end
            local vehicle = NetToVeh(result)

            SetVehicleRadioEnabled(vehicle, false)
            SetVehRadioStation(vehicle, 'OFF')
            if GarageConfig.Warp then
                SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
            end

            if  GetVehicleNumberPlateText(vehicle) ~= vehicleData.plate then
                SetVehicleNumberPlateText(vehicle, vehicleData.plate)
            end

            Wait(0)

            TriggerEvent('vehiclekeys:client:SetOwner', vehicleData.plate)

        end, vehicleData.vehicle, vehicleData.plate, garage, spawnPoint)
    end, vehicleData.plate)
end


local function CloseGarage()
    SendNUIMessage({
        action = 'close'
    })
    SetNuiFocus(false, false)
end


RegisterNUICallback('close', function(_, cb)
    cb('ok')
    CloseGarage()
end)

RegisterNUICallback('spawn', function(body, cb)
    cb('ok')
    CloseGarage()
    TrySpawnVehicle(body)
end)


RegisterNetEvent('garages:client:setHouseGarage', function(house, hasKey)
    if not house then return end
    local formattedHouseName = string.gsub(string.lower(house), ' ', '')
    local zoneName = 'house_' .. formattedHouseName
    if Config.Garages[zoneName] then
        if hasKey and not ZoneExists(zoneName) then
            CreateZone(zoneName, Config.Garages[zoneName], 'house')
        elseif not hasKey and ZoneExists(zoneName) then
            RemoveHouseZone(zoneName)
        end
    else
        lib.callback('garages:server:getHouseGarage', false, function(garageInfo) -- create garage if not exist
            local garageCoords = garageInfo.garage
            Config.Garages[zoneName] = {
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

RegisterNetEvent('garages:client:addHouseGarage', function(house, garageInfo) -- event from housing on garage creation
    local formattedHouseName = string.gsub(string.lower(house), ' ', '')

    Config.Garages['house_' .. formattedHouseName] = {
        takeVehicle = vector3(garageInfo.takeVehicle.x, garageInfo.takeVehicle.y, garageInfo.takeVehicle.z),
        spawnPoint = {
            vector4(
                garageInfo.takeVehicle.x,
                garageInfo.takeVehicle.y,
                garageInfo.takeVehicle.z,
                garageInfo.takeVehicle.w
            )
        },
        label = garageInfo.label,
        type = 'house',
        category = Config.VehicleClass['all']
    }
    TriggerServerEvent('garages:server:syncGarage', Config.Garages)
end)

RegisterNetEvent('garages:client:removeHouseGarage', function(house)
    Config.Garages['house' .. house] = nil
end)

AddEventHandler('playerReady', function()    
    if GetInvokingResource() and GetInvokingResource() ~= 'multichar' then return end
    CreateGarages()
end)

AddEventHandler('onResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    Wait(1000)
    CreateGarages()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        DestrouAllZone()
    end
end)
