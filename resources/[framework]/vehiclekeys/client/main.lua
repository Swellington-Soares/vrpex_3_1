local Config = require 'shared.config'

local KeysList = {}


local function isBlacklistedVehicle(vehicle)
    local isBlacklisted = false
    for _, v in ipairs(Config.NoLockVehicles) do
        if joaat(v) == GetEntityModel(vehicle) then
            isBlacklisted = true
            break;
        end
    end
    if Entity(vehicle).state.ignoreLocks or GetVehicleClass(vehicle) == 13 then isBlacklisted = true end
    return isBlacklisted
end


local function GiveKeys(id, plate)
    local distance = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(id))))
    if distance < 1.5 and distance > 0.0 then
        TriggerServerEvent('vehiclekeys:server:GiveVehicleKeys', id, plate)
    else
        vRP.notify(locale('notify.nonear'), nil, 3000, 'error')
    end
end

local function GetKeys()
    lib.callback('vehiclekeys:server:GetVehicleKeys', false, function(keysList)
        KeysList = keysList
    end)
end

local function HasKeys(plate)
    return KeysList[plate]
end

exports('HasKeys', HasKeys)

local function GetVehicle()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    return lib.getClosestVehicle(pos, Config.LockToggleDist, true)
end

local function AreKeysJobShared(veh)
    local vehName = GetDisplayNameFromVehicleModel(GetEntityModel(veh))
    local vehPlate = GetVehicleNumberPlateText(veh)
    local jobName = vRP.getPlayer().job.name
    local onDuty = vRP.getPlayer().job.onduty
    for job, v in pairs(Config.SharedKeys) do
        if job == jobName then
            if Config.SharedKeys[job].requireOnduty and not onDuty then return false end
            for _, vehicle in pairs(v.vehicles) do
                if string.upper(vehicle) == string.upper(vehName) then
                    if not HasKeys(vehPlate) then
                        TriggerServerEvent('vehiclekeys:server:AcquireVehicleKeys', vehPlate)
                    end
                    return true
                end
            end
        end
    end
    return false
end

local function addNoLockVehicles(model)
    Config.NoLockVehicles[#Config.NoLockVehicles + 1] = model
end

exports('addNoLockVehicles', addNoLockVehicles)

local function removeNoLockVehicles(model)
    for k, v in pairs(Config.NoLockVehicles) do
        if v == model then
            Config.NoLockVehicles[k] = nil
        end
    end
end

exports('removeNoLockVehicles', removeNoLockVehicles)

local function GetOtherPlayersInVehicle(vehicle)
    local otherPeds = {}
    for seat = -1, GetVehicleModelNumberOfSeats(GetEntityModel(vehicle)) - 2 do
        local pedInSeat = GetPedInVehicleSeat(vehicle, seat)
        if IsPedAPlayer(pedInSeat) and pedInSeat ~= PlayerPedId() then
            otherPeds[#otherPeds + 1] = pedInSeat
        end
    end
    return otherPeds
end


local function toggleEngine(veh)
    if veh then
        local EngineOn = GetIsVehicleEngineRunning(veh)
        if not isBlacklistedVehicle(veh) then
            if HasKeys(GetVehicleNumberPlateText(veh)) or AreKeysJobShared(veh) then
                if EngineOn then
                    SetVehicleEngineOn(veh, false, false, true)
                else
                    SetVehicleEngineOn(veh, true, true, true)
                end
            end
        end
    end
end

local function toggleVehicleLock(veh)
    if not veh then return end
    if not isBlacklistedVehicle(veh) then
        if HasKeys(GetVehicleNumberPlateText(veh)) or AreKeysJobShared(veh) then
            local ped = PlayerPedId()
            local vehLockStatus, curVeh = GetVehicleDoorLockStatus(veh), GetVehiclePedIsIn(ped, false)
            local object = 0

            if curVeh == 0 then
                if Config.LockToggleAnimation.Prop then
                    object = CreateObject(joaat(Config.LockToggleAnimation.Prop), 0, 0, 0, true, true, true)
                    while not DoesEntityExist(object) do Wait(1) end
                    AttachEntityToEntity(object, ped, GetPedBoneIndex(ped, Config.LockToggleAnimation.PropBone),
                        0.1, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
                end

                lib.requestAnimDict(Config.LockToggleAnimation.AnimDict)
                TaskPlayAnim(ped, Config.LockToggleAnimation.AnimDict, Config.LockToggleAnimation.Anim, 8.0, -8.0, -1, 52,
                    0, false, false, false)
                vRP.playSound(Config.LockAnimSound, 'self', false, 5.0)
                RemoveAnimDict(Config.LockToggleAnimation.AnimDict)
            end

            Citizen.CreateThread(function()
                if curVeh == 0 then Wait(Config.LockToggleAnimation.WaitTime) end
                if IsEntityPlayingAnim(ped, Config.LockToggleAnimation.AnimDict, Config.LockToggleAnimation.Anim, 3) then
                    StopAnimTask(ped, Config.LockToggleAnimation.AnimDict, Config.LockToggleAnimation.Anim, 8.0)
                end

                vRP.playSound(Config.LockToggleSound, 'self', false, 5.0)
                if object ~= 0 and DoesEntityExist(object) then
                    DeleteObject(object)
                    object = 0
                end
            end)

            NetworkRequestControlOfEntity(veh)
            if vehLockStatus == 1 then
                TriggerServerEvent('vehiclekeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(veh), 2)
                vRP.notify(locale('notify.vlock'), nil, 3000, 'inform')
            else
                TriggerServerEvent('vehiclekeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(veh), 1)
                vRP.notify(locale('notify.vunlock'), nil, 3000, 'success')
            end

            SetVehicleLights(veh, 2)
            Wait(250)
            SetVehicleLights(veh, 1)
            Wait(200)
            SetVehicleLights(veh, 0)
            Wait(300)
            ClearPedTasks(ped)
        else
            vRP.notify(locale('notify.ydhk'), nil, 5000, 'error')
        end
    else
        TriggerServerEvent('vehiclekeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(veh), 1)
    end
end

lib.addKeybind({
    description = 'Lock/Unlock Vehicle',
    name = 'lock_unlock_vehiche_key',
    defaultKey = 'L',
    defaultMapper = 'keyboard',
    onPressed = function(self)
        if LocalPlayer.state.disabledControls then return end
        toggleVehicleLock(GetVehicle())
    end
})

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() and vRP.getPlayer() ~= nil then
        GetKeys()
    end
end)

AddEventHandler('playerReady', function ()
    GetKeys()
end)

RegisterNetEvent('vehiclekeys:client:AddKeys', function(plate)
    KeysList[plate] = true
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        local vehicle = GetVehiclePedIsIn(ped, false)
        local vehicleplate = GetVehicleNumberPlateText(vehicle) --GetVehicleNumberPlateText(vehicle)
        if plate == vehicleplate then
            SetVehicleEngineOn(vehicle, false, false, false)
        end
    end
end)

RegisterNetEvent('vehiclekeys:client:RemoveKeys', function(plate)
    KeysList[plate] = nil
end)

RegisterNetEvent('vehiclekeys:client:ToggleEngine', function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
    if vehicle == 0 then return end
    local EngineOn = GetIsVehicleEngineRunning(vehicle)    
    if HasKeys(GetVehicleNumberPlateText(vehicle)) then
        if EngineOn then
            SetVehicleEngineOn(vehicle, false, false, true)
        else
            SetVehicleEngineOn(vehicle, true, false, true)
        end
    end
end)


RegisterNetEvent('qb-vehiclekeys:client:GiveKeys', function(id)
    local targetVehicle = GetVehicle()
    if targetVehicle then
        local targetPlate = GetVehicleNumberPlateText(targetVehicle)
        if HasKeys(targetPlate) then
            if id and type(id) == 'number' then -- Give keys to specific ID
                GiveKeys(id, targetPlate)
            else
                if IsPedSittingInVehicle(PlayerPedId(), targetVehicle) then -- Give keys to everyone in vehicle
                    local otherOccupants = GetOtherPlayersInVehicle(targetVehicle)
                    for p = 1, #otherOccupants do
                        TriggerServerEvent('vehiclekeys:server:GiveVehicleKeys', GetPlayerServerId(NetworkGetPlayerIndexFromPed(otherOccupants[p])), targetPlate)
                    end
                else -- Give keys to closest player
                    local otherPlayer = lib.getClosestPlayer(GetEntityCoords(cache.ped), 3.0, false)
                    if otherPlayer then
                        GiveKeys(GetPlayerServerId(otherPlayer), targetPlate)
                    end
                end
            end
        else
           vRP.notify(locale('notify.ydhk'), nil, 5000, 'error')
        end
    end
end)


RegisterNetEvent('vehiclekeys:client:SetOwner', function(plate)
    TriggerServerEvent('vehiclekeys:server:AcquireVehicleKeys', plate)
end)

exports('SetOwner', function (plate)
    TriggerServerEvent('vehiclekeys:server:AcquireVehicleKeys', plate)
end)