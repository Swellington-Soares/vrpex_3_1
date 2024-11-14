local
carRPM,
carSpeed,
carGear,
carIL,
carAcceleration,
carHandbrake,
carBrakeABS,
carLS_r,
carLS_o,
carLS_h,
carEngineHealth,
carLocked,
carSeatbelt,
carTrunk

local HideAll = true;

local vehicleThreadStarted = false
local inVehicle = false
local vehicle

local _hunger, _thirst, _stress, _health, _armour
local isPaused = false



CreateThread(function()
	DisplayRadar(false)
	-- for _, hud in next, { 1, 2, 3, 4, 6, 7, 8, 9, 13, 18, 20, 21, 22 } do
	-- 	SetHudComponentPosition(hud, 999.0, 999.0)
	-- end
end)

CreateThread(function()
	while true do
		isPaused = IsPauseMenuActive()
		local idle = 2000
		if HideAll then
			idle = 2000
		elseif not isPaused then
			local ped = PlayerPedId()
			local nhunger = LocalPlayer.state.hunger
			local nthirst = LocalPlayer.state.thirst
			local nstress = LocalPlayer.state.stress
			local nhealth = (GetEntityHealth(ped) / GetEntityMaxHealth(ped)) * 100.0
			local narmour = GetPedArmour(ped)

			local shouldUpdate = false
			if narmour ~= _armour or
				nthirst ~= _thirst or
				nstress ~= _stress or
				nhealth ~= _health or
				nhunger ~= _hunger then
				shouldUpdate = true
			end

			if shouldUpdate then
				_hunger = nhunger
				_thirst = nthirst
				_stress = nstress
				_health = nhealth
				_armour = narmour
				SendNUIMessage({
					action = 'HUD_UPDATE',
					ShowPlayerHud = true and not HideAll and not isPaused,
					hunger = nhunger,
					thirst = nthirst,
					stress = nstress,
					health = nhealth,
					armour = narmour,
				})
				idle = 500
			else
				idle = 2000
			end
		else
			SendNUIMessage({
				action = 'HUD_UPDATE',
				ShowPlayerHud = false
			})
		end
		Wait(idle)
	end
end)


local function startVehicleThread()
	if vehicleThreadStarted then return end
	if not inVehicle then return end
	vehicleThreadStarted = true
	CreateThread(function()
		local idle = 2000
		DisplayRadar(true)
		print('OK')
		while inVehicle do
			Wait(idle)
			if not DoesEntityExist(vehicle) then break end
			local playerPed = PlayerPedId()
			local playerCar = vehicle
			if playerCar and GetPedInVehicleSeat(playerCar, -1) == playerPed and not isPaused then
				local NcarRPM          = GetVehicleCurrentRpm(playerCar)
				local NcarSpeed        = GetEntitySpeed(playerCar)
				local NcarGear         = GetVehicleCurrentGear(playerCar)
				local NcarIL           = GetVehicleIndicatorLights(playerCar)
				local NcarAcceleration = IsControlPressed(0, 71)
				local NcarHandbrake    = GetVehicleHandbrake(playerCar)
				local NcarBrakeABS     = (GetVehicleWheelSpeed(playerCar, 0) <= 0.0) and (NcarSpeed > 0.0)
				local NcarLocked       = GetVehicleDoorLockStatus(playerCar) > 1				
				local NCarSeatBelt                 = Entity(playerCar).state.seat_belt
				local NCarTrunk                    = GetVehicleDoorAngleRatio(playerCar, 4) > 0.0 or
					GetVehicleDoorAngleRatio(playerCar, 5) > 0.0
				local NcarLS_r, NcarLS_o, NcarLS_h = GetVehicleLightsState(playerCar)
				local NcarEngineHealth             = GetVehicleEngineHealth(playerCar)

				local shouldUpdate                 = false

				if NcarRPM ~= carRPM or
					NcarSpeed ~= carSpeed or
					NcarGear ~= carGear or
					NcarIL ~= carIL or
					NcarAcceleration ~= carAcceleration or
					NcarHandbrake ~= carHandbrake or
					NcarBrakeABS ~= carBrakeABS or
					NcarLS_r ~= carLS_r or
					NcarLS_o ~= carLS_o or
					NcarLS_h ~= carLS_h or
					NCarSeatBelt ~= carSeatbelt or
					NcarLocked ~= carLocked or
					NCarTrunk ~= carTrunk
				then
					shouldUpdate = true
				end

				if shouldUpdate then
					carRPM          = NcarRPM
					carGear         = NcarGear
					carSpeed        = NcarSpeed
					carIL           = NcarIL
					carAcceleration = NcarAcceleration
					carHandbrake    = NcarHandbrake
					carBrakeABS     = NcarBrakeABS
					carLS_r         = NcarLS_r
					carLS_o         = NcarLS_o
					carLS_h         = NcarLS_h
					carEngineHealth = NcarEngineHealth
					carLocked       = NcarLocked
					carSeatbelt     = NCarSeatBelt
					carTrunk        = NCarTrunk
					SendNUIMessage({
						action                 = 'HUD_UPDATE',
						ShowVehicleHud         = true and not HideAll and not isPaused,
						CurrentCarRPM          = carRPM,
						CurrentCarGear         = carGear,
						CurrentCarSpeed        = math.ceil(carSpeed * 3.6),
						CurrentCarIL           = carIL,
						CurrentCarAcceleration = carAcceleration,
						CurrentCarHandbrake    = carHandbrake,
						CurrentCarABS          = GetVehicleWheelBrakePressure(playerCar, 0) > 0 and not carBrakeABS,
						CurrentCarLS_r         = carLS_r,
						CurrentCarLS_o         = carLS_o,
						CurrentCarLS_h         = carLS_h,
						CurrentCarEngineHealth = carEngineHealth,
						CurrentCarSeatBelt     = carSeatbelt,
						CurrentCarTrunkOpen    = carTrunk,
						CurrentCarLocked       = carLocked
					})
					idle = 500
				else
					idle = 1000
				end
			else
				SendNUIMessage({ ShowVehicleHud = false, action = 'HUD_UPDATE', })
				idle = 1000
			end
		end
		print('OK')
		DisplayRadar(false)
		vehicleThreadStarted = false
		SendNUIMessage({
			action = 'HUD_UPDATE',
			ShowVehicleHud = false,
		})
	end)
end

lib.onCache('vehicle', function(value)
	inVehicle = value
	if not value then return end
	vehicle = value
	startVehicleThread()
end)


lib.onCache('seat', function(value)
	if not value then return end
	if value == -1 and not vehicleThreadStarted then
		inVehicle = true
		vehicle = GetVehiclePedIsIn(cache.ped, false)
		startVehicleThread()
	elseif value ~= -1 and vehicleThreadStarted then
		inVehicle = false
	end
end)


AddStateBagChangeHandler('isLoggedIn', ('player:%s'):format(cache.serverId), function(_, _, value)
	HideAll = not value
end)


local function loadhud()
	if LocalPlayer.state.isLoggedIn then
		HideAll = false
		local _vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
		if _vehicle ~= 0 and GetPedInVehicleSeat(_vehicle, -1) == PlayerPedId() then
			inVehicle = true
			vehicle = _vehicle
			startVehicleThread()
		end
	end
end

RegisterNUICallback("loaded", function(data, cb)
	cb('ok')
	print('LOADED HUD')
	loadhud()
end)


exports('Hide', function(state)
	HideAll = state	
end)