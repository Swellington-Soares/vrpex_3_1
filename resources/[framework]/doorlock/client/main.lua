local PlayerData = vRP.getPlayer()
local isLoggedIn = LocalPlayer.state.isLoggedIn
local Config = Config
local canContinue = true
local playerPed = PlayerPedId()
local playerCoords = GetEntityCoords(playerPed)
local lastCoords = playerCoords
local nearbyDoors, closestDoor = {}, {}
local paused = false
local doorData = {}

-- Functions
function Draw3DText(coords, str)
	local onScreen, worldX, worldY = World3dToScreen2d(coords.x, coords.y, coords.z)
	local camCoords = GetGameplayCamCoord()
	local scale = 200 / (GetGameplayCamFov() * #(camCoords - coords))
	if onScreen then
		SetTextScale(1.0, 0.5 * scale)
		SetTextFont(4)
		SetTextColour(255, 255, 255, 255)
		SetTextEdge(2, 0, 0, 0, 150)
		SetTextProportional(1)
		SetTextOutline()
		SetTextCentre(1)
		BeginTextCommandDisplayText("STRING")
		AddTextComponentSubstringPlayerName(str)
		EndTextCommandDisplayText(worldX, worldY)
	end
end

local function raycastWeapon()
	local offset = GetOffsetFromEntityInWorldCoords(GetCurrentPedWeaponEntityIndex(playerPed), 0, 0, -0.01)
	local direction = GetGameplayCamRot(2)
	direction = vec2(direction.x * math.pi / 180.0, direction.z * math.pi / 180.0)
	local num = math.abs(math.cos(direction.x))
	direction = vec3((-math.sin(direction.y) * num), (math.cos(direction.y) * num), math.sin(direction.x))
	local destination = vec3(offset.x + direction.x * 30, offset.y + direction.y * 30, offset.z + direction.z * 30)
	local hit, entityHit, result
	local rayHandle = StartShapeTestLosProbe(offset, destination, -1, playerPed, 0)
	repeat
		result, hit, _, _, entityHit = GetShapeTestResult(rayHandle)
		Wait(0)
	until result ~= 1
	if GetEntityType(entityHit) == 3 then return hit, entityHit else return false, 0 end
end

local function RotationToDirection(rotation)
	local adjustedRotation =
	{
		x = (math.pi / 180) * rotation.x,
		y = (math.pi / 180) * rotation.y,
		z = (math.pi / 180) * rotation.z
	}
	local direction =
	{
		x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		z = math.sin(adjustedRotation.x)
	}
	return direction
end

local function RayCastGamePlayCamera(distance)
	local cameraRotation = GetGameplayCamRot(2)
	local cameraCoord = GetGameplayCamCoord(2)
	local direction = RotationToDirection(cameraRotation)
	local destination =
	{
		x = cameraCoord.x + direction.x * distance,
		y = cameraCoord.y + direction.y * distance,
		z = cameraCoord.z + direction.z * distance
	}
	local _, hit, endCoords, _, _ = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z,
		destination.x, destination.y, destination.z, -1, PlayerPedId(), 0))
	return hit == 1, endCoords
end


local function setTextCoords(data)
	local minDimension, maxDimension = GetModelDimensions(data.objName or data.objHash)
	local dimensions = maxDimension - minDimension
	local dx, dy = tonumber(dimensions.x), tonumber(dimensions.y)
	if dy <= -1 or dy >= 1 then dx = dy end
	if data.fixText then
		return GetOffsetFromEntityInWorldCoords(data.object, dx / 2, 0, 0)
	else
		return GetOffsetFromEntityInWorldCoords(data.object, -dx / 2, 0, 0)
	end
end

local function getTextCoords(door)
	if door.setText then return door.textCoords end
	return setTextCoords(door)
end

local function round(value, numDecimalPlaces)
	if not numDecimalPlaces then return math.floor(value + 0.5) end
	local power = 10 ^ numDecimalPlaces
	return math.floor((value * power) + 0.5) / (power)
end

local function displayNUIText(text)
	local color = Config.ChangeColor and (closestDoor.data.locked and Config.LockedColor or Config.UnlockedColor) or
		Config.DefaultColor
	SendNUIMessage({
		type = "setDoorText",
		enable = true,
		text = text,
		color = color
	})
	Wait(1)
end

local function HandleDoorDebug()
	if not Config.DoorDebug then return end

	CreateThread(function()
		while Config.DoorDebug do
			if closestDoor.data then
				Draw3DText(closestDoor.data.textCoords, closestDoor.data.doorLabel or 'Door Here')
			end
			Wait(0)
		end
	end)
end

local function hideNUI()
	SendNUIMessage({
		type = "setDoorText",
		enable = false
	})
	Wait(1)
end

local function playSound(door, src, enableSounds)
	if not Config.EnableSounds or not enableSounds then return end
	local origin
	if src and src ~= playerPed then src = NetworkGetEntityFromNetworkId(src) end
	if not src then
		origin = door.textCoords
	elseif src == playerPed then
		origin = playerCoords
	else
		origin =
			NetworkGetPlayerCoords(src)
	end
	local distance = #(playerCoords - origin)
	if distance < 10 then
		if not door.audioLock then
			if door.audioRemote then
				door.audioLock = { ['file'] = 'button-remote.ogg', ['volume'] = 0.08 }
				door.audioUnlock = { ['file'] = 'button-remote.ogg', ['volume'] = 0.08 }
			else
				door.audioLock = { ['file'] = 'door-bolt-4.ogg', ['volume'] = 0.1 }
				door.audioUnlock = { ['file'] = 'door-bolt-4.ogg', ['volume'] = 0.1 }
			end
		end
		local sfx_level = GetProfileSetting(300)
		local sound = door.locked and door.audioLock or door.audioUnlock
		SendNUIMessage({
			type = 'audio',
			audio = sound,
			distance = distance,
			sfx = sfx_level
		})
	end
end

local function doorAnim()
	if not Config.EnableAnimation then return end
	CreateThread(function()
		lib.requestAnimDict('anim@heists@keycard@')
		TaskPlayAnim(playerPed, "anim@heists@keycard@", "exit", 8.0, 1.0, -1, 48, 0, false, false, false)
		Wait(550)
		ClearPedTasks(playerPed)
		RemoveAnimDict('anim@heists@keycard@')
	end)
end

local function updateDoors(specificDoor)
	if #(playerCoords - lastCoords) > 30 then Wait(1000) end
	playerCoords = GetEntityCoords(playerPed)
	for doorID, data in pairs(Config.DoorList) do
		if not specificDoor or doorID == specificDoor then
			if data.doors then
				if not data.doorType then data.doorType = 'double' end
				for k, v in pairs(data.doors) do
					if #(playerCoords - v.objCoords) < 30 then
						if data.doorType == "doublesliding" then
							v.object = GetClosestObjectOfType(v.objCoords.x, v.objCoords.y, v.objCoords.z, 5.0,
								v.objName or v.objHash, false, false, false)
						else
							v.object = GetClosestObjectOfType(v.objCoords.x, v.objCoords.y, v.objCoords.z, 1.0,
								v.objName or v.objHash, false, false, false)
						end
						if v.object and v.object ~= 0 then
							v.doorHash = 'door_' .. doorID .. '_' .. k
							if not IsDoorRegisteredWithSystem(v.doorHash) then
								local objCoords = GetEntityCoords(v.object)
								local objHeading = GetEntityHeading(v.object)
								local hasHeading = v.objYaw or v.objHeading or false
								if v.objCoords ~= objCoords then v.objCoords = objCoords end -- Backwards compatibility fix
								if not hasHeading then
									v.objYaw = objHeading
								else
									if hasHeading ~= objHeading then -- Backwards compatibility fix
										v.objYaw = v.objYaw and objHeading or nil
										v.objHeading = v.objHeading and objHeading or nil
									end
								end
								AddDoorToSystem(v.doorHash, v.objName or v.objHash, v.objCoords.x, v.objCoords.y,
									v.objCoords.z, false, false, false)
								nearbyDoors[doorID] = true
								if data.locked then
									DoorSystemSetDoorState(v.doorHash, 4, false, false)
									DoorSystemSetDoorState(v.doorHash, 1, false, false)
								else
									DoorSystemSetDoorState(v.doorHash, 0, false, false)
								end
							end
						end
					elseif v.object then
						RemoveDoorFromSystem(v.doorHash)
						nearbyDoors[doorID] = nil
					end
				end
			elseif not data.doors then
				if not data.doorType then data.doorType = 'door' end
				if #(playerCoords - data.objCoords) < 30 then
					if data.doorType == "sliding" or data.doorType == "garage" then
						data.object = GetClosestObjectOfType(data.objCoords.x, data.objCoords.y, data.objCoords.z, 5.0,
							data.objName or data.objHash, false, false, false)
					else
						data.object = GetClosestObjectOfType(data.objCoords.x, data.objCoords.y, data.objCoords.z, 1.0,
							data.objName or data.objHash, false, false, false)
					end
					if data.object and data.object ~= 0 then
						data.doorHash = 'door_' .. doorID
						if not IsDoorRegisteredWithSystem(data.doorHash) then
							local objCoords = GetEntityCoords(data.object)
							local objHeading = GetEntityHeading(data.object)
							local hasHeading = data.objYaw or data.objHeading or false
							if data.objCoords ~= objCoords then data.objCoords = objCoords end -- Backwards compatibility fix
							if not hasHeading then
								data.objYaw = objHeading
							else
								if hasHeading ~= objHeading then -- Backwards compatibility fix
									data.objYaw = data.objYaw and objHeading or nil
									data.objHeading = data.objHeading and objHeading or nil
								end
							end
							data.objCoords = GetEntityCoords(data.object)
							AddDoorToSystem(data.doorHash, data.objName or data.objHash, data.objCoords.x,
								data.objCoords.y, data.objCoords.z, false, false, false)
							nearbyDoors[doorID] = true
							if data.locked then
								DoorSystemSetDoorState(data.doorHash, 4, false, false)
								DoorSystemSetDoorState(data.doorHash, 1, false, false)
							else
								DoorSystemSetDoorState(data.doorHash, 0, false, false)
							end
						end
					end
				elseif data.object then
					RemoveDoorFromSystem(data.doorHash)
					nearbyDoors[doorID] = nil
				end
			end
			-- set text coords
			if not data.setText and data.doors then
				for k, v in pairs(data.doors) do
					if k == 1 and DoesEntityExist(v.object) then
						data.textCoords = v.objCoords
					elseif k == 2 and DoesEntityExist(v.object) and data.textCoords then
						local textDistance = data.textCoords - v.objCoords
						data.textCoords = data.textCoords - (textDistance / 2)
						data.setText = true
					end
					if k == 2 and data.textCoords and (data.doorType == "sliding" or data.doorType == "garage") then
						if GetEntityHeightAboveGround(v.object) < 1 then
							data.textCoords = vec3(data.textCoords.x, data.textCoords.y, data.textCoords.z + 1.2)
						end
					end
				end
			elseif not data.setText and not data.doors and DoesEntityExist(data.object) then
				if data.doorType == "garage" then
					data.textCoords = data.objCoords
					data.setText = true
				else
					data.textCoords = setTextCoords(data)
					data.setText = true
				end
				if data.doorType == "sliding" or data.doorType == "garage" then
					if GetEntityHeightAboveGround(data.object) < 1 then
						data.textCoords = vec3(data.textCoords.x, data.textCoords.y, data.textCoords.z + 1.6)
					end
				end
			end
		end
	end
	lastCoords = playerCoords
end

local function isAuthorized(door)
	if door.allAuthorized then return true end

	if door.authorizedJobs then
		if door.authorizedJobs[PlayerData.job.name] and PlayerData.job.rank >= door.authorizedJobs[PlayerData.job.name] then
			return true
		elseif type(door.authorizedJobs[1]) == 'string' then
			for _, job in pairs(door.authorizedJobs) do -- Support for old format
				if job == PlayerData.job.name then return true end
			end
		end
	end

	if door.authorizedGangs then
		if door.authorizedGangs[PlayerData.gang.name] and PlayerData.gang.rank >= door.authorizedGangs[PlayerData.gang.name] then
			return true
		elseif type(door.authorizedGangs[1]) == 'string' then
			for _, gang in pairs(door.authorizedGangs) do -- Support for old format
				if gang == PlayerData.gang.name then return true end
			end
		end
	end

	if door.authorizedCitizenIDs then
		if door.authorizedCitizenIDs[PlayerData.char_id] then
			return true
		elseif type(door.authorizedCitizenIDs[1]) == 'string' then
			for _, id in pairs(door.authorizedCitizenIDs) do -- Support for old format
				if id == PlayerData.char_id then return true end
			end
		end
	end

	if door.authorizedUserIds then
		if door.authorizedUserIds[PlayerData.user_id] then
			return true
		elseif type(door.authorizedUserIds[1]) == 'number' then
			for _, id in pairs(door.authorizedUserIds) do -- Support for old format
				if id == PlayerData.user_id then return true end
			end
		end
	end

	if door.authorizedRegistrations then
		if door.authorizedRegistrations[PlayerData.registration] then
			return true
		elseif type(door.authorizedRegistrations[1]) == 'string' then
			for _, id in pairs(door.authorizedRegistrations) do -- Support for old format
				if id == PlayerData.registration then return true end
			end
		end
	end



	if door.items then
		local p = promise.new()
		lib.callback('doorlock:server:checkItems', false, function(result)
			p:resolve(result)
		end, door.items, door.needsAllItems)
		return Citizen.Await(p)
	end

	return false
end

function SetupDoors()
	local p = promise.new()
	lib.callback('doorlock:server:setupDoors', false, function(result)				
		p:resolve(result)
	end)
	Config.DoorList = Citizen.Await(p)
	-- PlayerData = vRP.getPlayer()
	-- isLoggedIn = LocalPlayer.state.isLoggedIn
	print('SetupDoors')
end

-- Events

RegisterNetEvent('playerReady', function()
	lib.callback('doorlock:server:setupDoors', false, function(result)
		Config.DoorList = result
		PlayerData = vRP.getPlayer()
		isLoggedIn = true
	end)
end)

-- RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
-- 	isLoggedIn = false
-- 	PlayerData = {}
-- end)

RegisterNetEvent('vRP:SetPlayerData', function(val)
	PlayerData = val
end)

RegisterNetEvent('doorlock:client:setState', function(serverId, doorID, state, src, enableSounds, enableAnimation)	
	if not Config.DoorList[doorID] then return end
	if enableAnimation == nil then enableAnimation = true end
	if enableSounds == nil then enableSounds = true end
	if serverId == PlayerData.source and enableAnimation then doorAnim() end
	Config.DoorList[doorID].locked = state
	updateDoors(doorID)
	local current = Config.DoorList[doorID]
	while true do
		if current.doors then
			if not current.doorType then current.doorType = 'double' end
			for k, v in pairs(current.doors) do
				if not IsDoorRegisteredWithSystem(v.doorHash) then return end
				v.currentHeading = GetEntityHeading(v.object)
				v.doorState = DoorSystemGetDoorState(v.doorHash)
				if current.doorType == "doublesliding" then
					DoorSystemSetAutomaticRate(v.doorHash, v.doorRate or 1.0, false, false)
					if current.locked then
						DoorSystemSetDoorState(v.doorHash, 1, false, false)
						DoorSystemSetAutomaticDistance(v.doorHash, 0.0, false, false)
						if k == 2 then
							playSound(current, src, enableSounds)
							return
						end
					else
						DoorSystemSetDoorState(v.doorHash, 0, false, false)
						DoorSystemSetAutomaticDistance(v.doorHash, 30.0, false, false)
						if k == 2 then
							playSound(current, src, enableSounds)
							return
						end
					end
				elseif current.locked and v.doorState == 4 then
					DoorSystemSetDoorState(v.doorHash, 1, false, false)
					if current.doors[1].doorState == current.doors[2].doorState then
						playSound(current, src, enableSounds)
						return
					end
				elseif not current.locked then
					DoorSystemSetDoorState(v.doorHash, 0, false, false)
					if current.doors[1].doorState == current.doors[2].doorState then
						playSound(current, src, enableSounds)
						return
					end
				else
					if round(v.currentHeading, 0) == round(v.objYaw or v.objHeading, 0) then
						DoorSystemSetDoorState(v.doorHash, 4, false, false)
					end
				end
			end
		else
			if not IsDoorRegisteredWithSystem(current.doorHash) then return end
			if not current.doorType then current.doorType = 'door' end
			current.currentHeading = GetEntityHeading(current.object)
			current.doorState = DoorSystemGetDoorState(current.doorHash)
			if current.doorType == "sliding" or current.doorType == "garage" then
				DoorSystemSetAutomaticRate(current.doorHash, current.doorRate or 1.0, false, false)
				if current.locked then
					DoorSystemSetDoorState(current.doorHash, 1, false, false)
					DoorSystemSetAutomaticDistance(current.doorHash, 0.0, false, false)
					playSound(current, src, enableSounds)
					return
				else
					DoorSystemSetDoorState(current.doorHash, 0, false, false)
					DoorSystemSetAutomaticDistance(current.doorHash, 30.0, false, false)
					playSound(current, src, enableSounds)
					return
				end
			elseif current.locked and current.doorState == 4 then
				DoorSystemSetDoorState(current.doorHash, 1, false, false)
				playSound(current, src, enableSounds)
				return
			elseif not current.locked then
				DoorSystemSetDoorState(current.doorHash, 0, false, false)
				playSound(current, src, enableSounds)
				return
			else
				if round(current.currentHeading, 0) == round(current.objYaw or current.objHeading, 0) then
					DoorSystemSetDoorState(current.doorHash, 4, false, false)
				end
			end
		end
		Wait(0)
	end
end)

-- RegisterNetEvent('lockpicks:UseLockpick', function(isAdvanced)
--     if not closestDoor.data or not next(closestDoor.data) or PlayerData.metadata['isdead'] or PlayerData.metadata['ishandcuffed'] or (not closestDoor.data.pickable and not closestDoor.data.lockpick) or not closestDoor.data.locked then
--         return
--     end

--     local difficulty = isAdvanced and 'easy' or 'medium' -- Use 'easy' difficulty for advanced lockpicks, medium for others
--     local success = exports['qb-minigames']:Skillbar(difficulty)
--     if success then
--         vRP.notify(locale("success.lockpick_success"), 'success', 2500)
--         -- Determine which coordinates to face based on door data
--         local coordsToFace = closestDoor.data.doors and closestDoor.data.doors[1].objCoords or closestDoor.data.objCoords
--         TaskTurnPedToFaceCoord(playerPed, coordsToFace.x, coordsToFace.y, coordsToFace.z, 0)
--         -- Wait for the ped to turn towards the door
--         Wait(300)
--         local count = 0
--         while GetIsTaskActive(playerPed, 225) and count < 150 do
--             Wait(10)
--             count = count + 1
--         end
--         Wait(1800)
--         -- Unlock the door
--         TriggerServerEvent('doorlock:server:updateState', closestDoor.id, false, false, true, false)
--     else
--         vRP.notify(locale("error.lockpick_fail"), 'error', 2500)
--         if isAdvanced then
--             local chanceToRemove = math.random(1,100) <= 17
--             if chanceToRemove then
--                 TriggerServerEvent("doorlock:server:removeLockpick", "advancedlockpick")
--                 TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items["advancedlockpick"], "remove")
--             end
--         else
--             TriggerServerEvent("doorlock:server:removeLockpick", "lockpick")
--             TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items["lockpick"], "remove")
--         end
--     end
-- end)

RegisterNetEvent('doorlock:client:addNewDoor', function()
	canContinue = false
	hideNUI()
	if not Config.SaveDoorDialog then doorData = {} end


	local input = lib.inputDialog(locale("general.newdoor_menu_title"), {
		{
			label = locale("general.configfile_title"),
			name = "configfile",
			default = Config.SaveDoorDialog and doorData.configfile,
			type = "input",
			required = true
		},
		{
			label = locale("general.dooridentifier_title"),
			name = "dooridentifier",
			default = Config.SaveDoorDialog and doorData.dooridentifier,
			type = "input",
			required = true
		},
		{
			label = locale("general.doorlabel_title"),
			name = "doorlabel",
			default = Config.SaveDoorDialog and doorData.doorlabel,
			type = "input",
			required = false
		},
		{
			label = locale("general.doortype_title"),
			name = "doortype",
			type = "select",
			options = {
				{ value = "door",          label = locale("general.doortype_door") },
				{ value = "double",        label = locale("general.doortype_double") },
				{ value = "sliding",       label = locale("general.doortype_sliding") },
				{ value = "doublesliding", label = locale("general.doortype_doublesliding") },
				{ value = "garage",        label = locale("general.doortype_garage") }
			},
			default = Config.SaveDoorDialog and doorData.doortype
		},
		{
			label = locale("general.job_authorisation_menu"),
			name = "job",
			default = Config.SaveDoorDialog and doorData.job,
			type = "input",
			required = false
		},
		{
			label = locale("general.gang_authorisation_menu"),
			name = "gang",
			default = Config.SaveDoorDialog and doorData.gang,
			type = "input",
			required = false
		},
		{
			label = locale("general.citizenid_authorisation_menu"),
			name = "cid",
			default = Config.SaveDoorDialog and doorData.cid,
			type = "input",
			required = false
		},
		{
			label = locale("general.item_authorisation_menu"),
			name = "item",
			default = Config.SaveDoorDialog and doorData.item,
			type = "input",
			required = false
		},
		{
			label = locale("general.distance_menu"),
			name = "distance",
			default = Config.SaveDoorDialog and doorData.distance,
			type = "number",
			required = true
		},
		{
			label = locale("general.lock_settings"),
			name = "locksettings",
			type = "checkbox",
			options = {
				{ value = "locked",     label = locale("general.locked_menu"),     checked = (Config.SaveDoorDialog and doorData.locked) },
				{ value = "pickable",   label = locale("general.pickable_menu"),   checked = (Config.SaveDoorDialog and doorData.pickable == 'true') },
				{ value = "cantunlock", label = locale("general.cantunlock_menu"), checked = (Config.SaveDoorDialog and doorData.cantunlock == 'true') },
				{ value = "hidelabel",  label = locale("general.hidelabel_menu"),  checked = (Config.SaveDoorDialog and doorData.hidelabel == 'true') }
			}
		}
	})

	local dialog = {}

	if input then
		dialog.configfile = input[1] -- arquivo de configuração
		dialog.dooridentifier = input[2] -- identificador da porta
		dialog.doorlabel = input[3] -- rótulo da porta
		dialog.doortype = input[4] -- tipo de porta selecionado
		dialog.job = input[5]      -- autorização do trabalho
		dialog.gang = input[6]     -- autorização da gangue
		dialog.cid = input[7]      -- autorização por citizen ID
		dialog.item = input[8]     -- autorização por item
		dialog.distance = input[9] -- distância da porta
		dialog.locksettings = input[10] -- opções de configuração de travamento		
	end



	if not input or not next(dialog) then
		canContinue = true
		return
	end

	doorData = dialog

	local identifier = doorData.configfile .. '-' .. doorData.dooridentifier
	if Config.DoorList[identifier] then
		vRP.notify('Door Creator', locale("error.door_identifier_exists", identifier), 3000, 'error')
		canContinue = true
		return
	end

	if doorData.configfile == '' then doorData.configfile = false end
	if doorData.job == '' then doorData.job = false end
	if doorData.gang == '' then doorData.gang = false end
	if doorData.cid == '' then doorData.cid = false end
	if doorData.item == '' then doorData.item = false end
	if doorData.doorlabel == '' then doorData.doorlabel = nil end
	if doorData.pickable ~= 'true' then doorData.pickable = nil end
	if doorData.cantunlock ~= 'true' then doorData.cantunlock = nil end
	if doorData.hidelabel ~= 'true' then doorData.hidelabel = nil end

	doorData.locked = doorData.locked == 'true'
	doorData.distance = tonumber(doorData.distance)
	if doorData.doortype == 'door' or doorData.doortype == 'sliding' or doorData.doortype == 'garage' then
		SendNUIMessage({
			type = "setText",
			aim = "block"
		})
		local heading, result, entityHit
		local entity, coords, model = 0, 0, 0
		while true do
			if IsPlayerFreeAiming(PlayerId()) then
				result, entityHit = raycastWeapon()
				if result and entityHit ~= entity then
					SetEntityDrawOutline(entity, false)
					SetEntityDrawOutline(entityHit, true)
					entity = entityHit
					coords = GetEntityCoords(entity)
					model = GetEntityModel(entity)
					heading = GetEntityHeading(entity)
					SendNUIMessage({
						type = "setText",
						aim = "none",
						details = "block",
						coords = coords,
						heading = heading,
						hash = model
					})
				end
				if entity and IsControlPressed(0, 24) then break end
			end
			Wait(0)
		end
		SetEntityDrawOutline(entity, false)
		SendNUIMessage({
			type = "setText",
			aim = "none",
			details = "none",
			coords = "",
			heading = "",
			hash = ""
		})
		if not model or model == 0 then
			vRP.notify('Door Creator', locale("error.door_not_found"), 3000, 'error')
			canContinue = true
			return
		end
		result = DoorSystemFindExistingDoor(coords.x, coords.y, coords.z, model)
		if result then
			vRP.notify('Door Creator', locale("error.door_registered"), 3000, 'error')
			canContinue = true
			return
		end
		doorData.doorHash = 'door_' .. doorData.dooridentifier
		AddDoorToSystem(doorData.doorHash, model, coords, false, false, false)
		DoorSystemSetDoorState(doorData.doorHash, 4, false, false)
		coords = GetEntityCoords(entity)
		heading = GetEntityHeading(entity)
		RemoveDoorFromSystem(doorData.doorHash)
		doorData.entity = entity
		doorData.coords = coords
		doorData.model = model
		doorData.heading = heading

		local objName = GetEntityArchetypeName(entity)
		if objName then
			doorData.objName = objName
		else
			doorData.objHash = model
		end

		TriggerServerEvent('doorlock:server:saveNewDoor', doorData, false)
		canContinue = true
	else
		local result, entityHit
		local entity, coords, heading, model = { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }
		for i = 1, 2 do
			SendNUIMessage({
				type = "setText",
				aim = "block",
				details = "none",
				coords = "",
				heading = "",
				hash = ""
			})
			while true do
				if IsPlayerFreeAiming(PlayerId()) then
					result, entityHit = raycastWeapon()
					if result and entityHit ~= entity[i] then
						SetEntityDrawOutline(entity[i], false)
						SetEntityDrawOutline(entityHit, true)
						entity[i] = entityHit
						coords[i] = GetEntityCoords(entity[i])
						model[i] = GetEntityModel(entity[i])
						heading[i] = GetEntityHeading(entity[i])
						SendNUIMessage({
							type = "setText",
							aim = "none",
							details = "block",
							coords = coords[i],
							heading = heading[i],
							hash = model[i]
						})
					end
					if entity[i] and IsControlPressed(0, 24) then break end
				end
				Wait(0)
			end
			Wait(200)
		end
		SetEntityDrawOutline(entity[1], false)
		SetEntityDrawOutline(entity[2], false)
		SendNUIMessage({
			type = "setText",
			aim = "none",
			details = "none",
			coords = "",
			heading = "",
			hash = ""
		})
		if not model[1] or model[1] == 0 or not model[2] or model[2] == 0 then
			vRP.notify('Door Creator', locale("error.door_not_found"), 3000, 'error')
			return
		end
		if entity[1] == entity[2] then
			vRP.notify('Door Creator', locale("error.same_entity"), 3000, 'error')
			canContinue = true
			return
		end
		doorData.doorHash = {}
		for i = 1, 2 do
			result = DoorSystemFindExistingDoor(coords[i].x, coords[i].y, coords[i].z, model[i])
			if result then
				vRP.notify('Door Creator', locale("error.door_registered"), 3000, 'error')
				canContinue = true
				return
			end
			doorData.doorHash[i] = 'door_' .. doorData.dooridentifier .. '_' .. i
			AddDoorToSystem(doorData.doorHash[i], model[i], coords[i], false, false, false)
			DoorSystemSetDoorState(doorData.doorHash[i], 4, false, false)
			coords[i] = GetEntityCoords(entity[i])
			heading[i] = GetEntityHeading(entity[i])
			RemoveDoorFromSystem(doorData.doorHash[i])
		end
		doorData.entity = entity
		doorData.coords = coords
		doorData.model = model		
		doorData.heading = heading

		doorData.objHash = model
		local name1 = GetEntityArchetypeName( entity[1] )
		local name2 = GetEntityArchetypeName( entity[2] )
		if name1 and name2 then
			doorData.objName = { name1, name2 }
		end

		TriggerServerEvent('doorlock:server:saveNewDoor', doorData, true)
		canContinue = true
	end
end)

RegisterNetEvent('doorlock:client:newDoorAdded', function(data, id, creatorSrc)
	Config.DoorList[id] = data
	TriggerEvent('doorlock:client:setState', creatorSrc, id, data.locked, false, true, true)
end)

RegisterNetEvent('doorlock:client:ToggleDoorDebug', function()
	Config.DoorDebug = not Config.DoorDebug
	HandleDoorDebug()
end)

-- Commands

RegisterCommand('toggledoorlock', function()
	if not closestDoor.data or not next(closestDoor.data) then return end

	local distanceCheck = closestDoor.distance > (closestDoor.data.distance or closestDoor.data.maxDistance)
	local unlockableCheck = (closestDoor.data.cantUnlock and closestDoor.data.locked)
	local busyCheck = IsEntityDead(PlayerPedId()) or LocalPlayer.state.handcuffed
	if distanceCheck or unlockableCheck or busyCheck then return end

	playerPed = PlayerPedId()
	local veh = GetVehiclePedIsIn(playerPed, false)
	if veh then
		CreateThread(function()
			local siren = IsVehicleSirenOn(veh)
			for _ = 0, 100 do
				DisableControlAction(0, 86, true)
				SetHornEnabled(veh, false)
				if not siren then SetVehicleSiren(veh, false) end
				Wait(0)
			end
			SetHornEnabled(veh, true)
		end)
	end
	local locked = not closestDoor.data.locked
	local src
	if closestDoor.data.audioRemote then
		src = NetworkGetNetworkIdFromEntity(playerPed)
	end

	TriggerServerEvent('doorlock:server:updateState', closestDoor.id, locked, src, false, false, true, true) -- Broadcast new state of the door to everyone
end, false)

TriggerEvent("chat:removeSuggestion", "/toggledoorlock")
RegisterKeyMapping('toggledoorlock', locale("general.keymapping_description"), 'keyboard', 'E')


RegisterCommand('remotetriggerdoor', function()
	local hit, raycastCoords = RayCastGamePlayCamera(Config.RemoteTriggerDistance)
	if not hit then return end

	local nearestDoor = nil
	for k in pairs(nearbyDoors) do
		local door = Config.DoorList[k]
		local canTrigger = door.remoteTrigger
		local distance = #(raycastCoords - getTextCoords(door))

		if canTrigger and (not nearestDoor or distance < nearestDoor.distance) and distance < math.max(door.distance, Config.RemoteTriggerMinDistance) then
			nearestDoor = {
				data = door,
				id = k,
				distance = distance
			}
		end
	end

	if not nearestDoor then return end

	local unlockableCheck = (nearestDoor.data.cantUnlock and nearestDoor.data.locked)
	local busyCheck = false --PlayerData.metadata['isdead'] or PlayerData.metadata['inlaststand'] or		PlayerData.metadata['ishandcuffed']
	if unlockableCheck or busyCheck then return end

	playerPed = PlayerPedId()
	local veh = GetVehiclePedIsIn(playerPed, false)
	if veh then
		CreateThread(function()
			for _ = 0, 100 do
				DisableControlAction(0, 74, true)
				Wait(0)
			end
		end)
	end

	TriggerServerEvent('doorlock:server:updateState', nearestDoor.id, not nearestDoor.data.locked,
		NetworkGetNetworkIdFromEntity(playerPed), false, false, true, true) -- Broadcast new state of the door to everyone
end, false)
TriggerEvent("chat:removeSuggestion", "/remotetriggerdoor")
RegisterKeyMapping('remotetriggerdoor', locale("general.keymapping_remotetriggerdoor"), 'keyboard', 'H')

-- Threads

CreateThread(function()
	if Config.PersistentDoorStates and isLoggedIn then
		Wait(1000)
		SetupDoors()
	end -- Required for pulling in door states properly from live ensures

	updateDoors()
	HandleDoorDebug()
	while true do
		local sleep = 100
		if isLoggedIn and canContinue then
			playerPed = PlayerPedId()
			playerCoords = GetEntityCoords(playerPed)
			if not closestDoor.id then
				local distance = #(playerCoords - lastCoords)
				if distance > 15 then
					updateDoors()
					sleep = 1000
				else
					for k in pairs(nearbyDoors) do
						local door = Config.DoorList[k]
						if door.setText and door.textCoords then
							distance = #(playerCoords - door.textCoords)
							if distance < (closestDoor.distance or 15) then
								if distance < (door.distance or door.maxDistance) then
									closestDoor = { distance = distance, id = k, data = door }
									sleep = 0
								end
							end
						end
					end
				end
			end
			if closestDoor.id then
				while isLoggedIn do
					if not paused and IsPauseMenuActive() then
						hideNUI()
						paused = true
					elseif paused then
						if not IsPauseMenuActive() then paused = false end
					else
						playerCoords = GetEntityCoords(playerPed)
						closestDoor.distance = #(closestDoor.data.textCoords - playerCoords)
						if closestDoor.distance < (closestDoor.data.distance or closestDoor.data.maxDistance) then
							local authorized = isAuthorized(closestDoor.data)							
							local displayText = ""

							if not closestDoor.data.hideLabel and Config.UseDoorLabelText and closestDoor.data.doorLabel then
								displayText = closestDoor.data.doorLabel
							else
								if not closestDoor.data.locked and not authorized then
									displayText = locale("general.unlocked")
								elseif not closestDoor.data.locked and authorized then
									displayText = locale("general.unlocked_button")
								elseif closestDoor.data.locked and not authorized then
									displayText = locale("general.locked")
								elseif closestDoor.data.locked and authorized then
									displayText = locale("general.locked_button")
								end
							end

							if displayText ~= "" and (closestDoor.data.hideLabel == nil or not closestDoor.data.hideLabel) then
								displayNUIText(displayText)
							end
						else
							hideNUI()
							break
						end
					end
					Wait(100)
				end
				closestDoor = {}
				sleep = 0
			end
		end
		Wait(sleep)
	end
end)
