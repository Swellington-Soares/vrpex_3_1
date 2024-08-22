local isInVehicle = false
local isEnteringVehicle = false
local currentVehicle = 0
local currentSeat = 0

CreateThread(function()
    while true do
        Wait(50)
        local ped = PlayerPedId()
        if not isInVehicle and not IsPlayerDead(PlayerId()) and not LocalPlayer.state.isDead then
            local vehicle = GetVehiclePedIsTryingToEnter(ped)
            if DoesEntityExist(vehicle) and not isEnteringVehicle then
                -- trying to enter a vehicle!
                local seat = GetSeatPedIsTryingToEnter(ped)
                local netId = VehToNet(vehicle)
                local model = GetEntityModel(vehicle)
                local name = GetDisplayNameFromVehicleModel(model)
                isEnteringVehicle = true
                TriggerEvent("baseevents:enteringVehicle", vehicle, seat, name, model, netId)
                TriggerServerEvent('baseevents:enteringVehicle', vehicle, seat, name, model, netId)
            elseif not DoesEntityExist(vehicle) and not IsPedInAnyVehicle(ped, true) and
                isEnteringVehicle then
                -- vehicle entering aborted
                TriggerServerEvent('baseevents:enteringAborted')
                TriggerEvent('baseevents:enteringAborted')
                isEnteringVehicle = false
            elseif IsPedInAnyVehicle(ped, false) then
                -- suddenly appeared in a vehicle, possible teleport
                isEnteringVehicle = false
                isInVehicle = true
                currentVehicle = GetVehiclePedIsUsing(ped)
                currentSeat = GetPedVehicleSeat(ped)
                local model = GetEntityModel(currentVehicle)
                local name = GetDisplayNameFromVehicleModel(model)
                local netId = VehToNet(currentVehicle)
                TriggerServerEvent('baseevents:enteredVehicle', currentVehicle, currentSeat, name, model, netId)
                TriggerEvent('baseevents:enteredVehicle', currentVehicle, currentSeat, name, model, netId)
            end
        elseif isInVehicle then
            if not IsPedInAnyVehicle(ped, false) or IsPlayerDead(PlayerId()) or LocalPlayer.state.isDead then
                -- bye, vehicle
                local model = GetEntityModel(currentVehicle)
                local name = GetDisplayNameFromVehicleModel(model)
                local netId = VehToNet(currentVehicle)
                TriggerServerEvent('baseevents:leftVehicle', currentVehicle, currentSeat,
                    name, model, netId)
                TriggerEvent('baseevents:leftVehicle', currentVehicle, currentSeat,
                    name, model, netId)
                isInVehicle = false
                currentVehicle = 0
                currentSeat = 0
            end
        end

    end
end)

function GetPedVehicleSeat(ped)
    local vehicle = GetVehiclePedIsIn(ped, false)
    for i = -2, GetVehicleMaxNumberOfPassengers(vehicle) do
        if (GetPedInVehicleSeat(vehicle, i) == ped) then
            return i
        end
    end
    return -2
end
