local inVehicle = false
local vehicle 
local beltlock = false
local isHudShow = false

local hunger = 0.0
local thirst = 0.0
local stress = 0.0


AddStateBagChangeHandler('hunger', ("player:%s"):format(cache.serverId), function (_, _, value)
	hunger = value or 0.0	
end)

AddStateBagChangeHandler('thirst', ("player:%s"):format(cache.serverId), function (_, _, value)
	thirst = value or 0.0	
end)

AddStateBagChangeHandler('stress', ("player:%s"):format(cache.serverId), function (_, _, value)
	stress = value or 0.0	
end)

AddEventHandler('pma-voice:setTalkingMode', function()	
	SendNUIMessage({ voice = LocalPlayer.state.proximity.mode})
end)


CreateThread(function()
	DisplayRadar(false)	
	Wait(0)
end)

local threadVehicleStarted = false

local function vehicleThread()
	if threadVehicleStarted then return end
	threadVehicleStarted = true
	CreateThread(function ()		
		DisplayRadar(true)		
		lib.print.info('STARTED')
		while inVehicle do			
			local radio = LocalPlayer.state.radioChannel
			SendNUIMessage({
				vehicle = true and isHudShow,
				locked = GetVehicleDoorLockStatus(vehicle),
				speed = GetEntitySpeed(vehicle) * 3.6,
				fuel = GetVehicleFuelLevel(vehicle),
				rpm = GetVehicleCurrentRpm(vehicle),
				healthcar = GetVehicleEngineHealth(vehicle),
				VHeadlight = GetVehicleLightsState(vehicle),
				belt = beltlock,
				radio = radio > 0 and radio or 'Offline'
			})
			Wait(500)
		end		
			
		threadVehicleStarted = false
		SendNUIMessage({vehicle = false})
		lib.print.info('FINALIZED')
	end)
end


local threadStatusStarted = false

local function statusThread()
	if threadStatusStarted then return end
	threadStatusStarted = true
	CreateThread(function()
		while statusThread do
			SendNUIMessage({
				hud = true and isHudShow,
				health = (GetEntityHealth(cache.ped) / GetEntityMaxHealth(cache.ped)) * 100.0,
				armour = GetPedArmour(cache.ped),
				thirst = thirst,
				hunger = hunger,
				stress = stress, 
				talking = MumbleIsPlayerTalking(cache.playerId)
			})
			Wait(250)
		end
		threadStatusStarted = false
	end)
end

lib.onCache('vehicle', function(value)	
	if not value then
		inVehicle = false
		return
	end
	vehicle = value
	inVehicle = true	
	vehicleThread()
end)

-- lib.onCache('weapon', function(value)
-- 	if not value then return end
-- end)

exports('showHud', function ()
	if isHudShow then return end	
	isHudShow = true
	statusThread()
	if GetVehiclePedIsIn(cache.ped, false) then
		vehicleThread()
	end
end)

exports('hideHud', function ()
	if not isHudShow then return end
	isHudShow = false
end)

AddEventHandler('playerReady', function()
	Wait(1000)
	exports.hud:showHud()
end)