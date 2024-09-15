---@diagnostic disable: param-type-mismatch


local function showWarning(msg)
	print(('^3%s: %s^0'):format(locale("general.warning"), msg))
end

---Remove Item from Inventory
---@param src number | string player server id
---@param item? OxServerItem
local function removeItem(src, item)
	if not item then return end
	if Config.Consumables[item.name] then
		exports.ox_inventory:RemoveItem(src, item.name,
			item.count >= Config.Consumables[item.name] and Config.Consumables[item.name] or 1)
	end
end

---Check And Remove Item From Inventory
---@param source number | string player server id
---@param item OxServerItem
---@param shouldRemove boolean
---@return boolean
local function checkAndRemoveItem(source, item, shouldRemove)
	if not item then return false end
	if shouldRemove then
		removeItem(source, item)
	end
	return true
end

---Check Items
---@param src number | string
---@param items { name : string, amount: number }
---@param needsAll boolean
---@param shouldRemove boolean
---@return boolean
local function checkItems(src, items, needsAll, shouldRemove)
	if needsAll == nil then needsAll = true end
	local isTable = type(items) == 'table'
	local isArray = isTable and table.type(items) == 'array' or false
	local totalItems = 0
	local count = 0
	if isTable then for _ in pairs(items) do totalItems += 1 end else totalItems = #items end
	local kvIndex
	if isArray then kvIndex = 2 else kvIndex = 1 end
	if isTable then
		for k, v in pairs(items) do
			local itemKV = { k, v }
			local item = exports.ox_inventory:GetItem(src, itemKV[kvIndex]) --  Player.Functions.GetItemByName(itemKV[kvIndex])

			if needsAll then
				if checkAndRemoveItem(src, item, false) then
					count += 1
				end
			else
				if checkAndRemoveItem(src, item, shouldRemove) then
					return true
				end
			end
		end

		if count == totalItems then
			for k, v in pairs(items) do
				local itemKV = { k, v }
				local item = exports.ox_inventory:GetItem(src, itemKV[kvIndex])
				checkAndRemoveItem(Player, item, shouldRemove)
			end
			return true
		end
	else -- Single item as string
		local item = exports.ox_inventory:Search(src, items)
		return checkAndRemoveItem(Player, item, shouldRemove)
	end
	return false
end

local function isAuthorized(xPlayer, door, usedLockpick)

	lib.print.info('PLAYER', xPlayer)

	if door.allAuthorized then return true end
	if not xPlayer then return false end


	if Config.AdminAccess and vRP.hasGroup(xPlayer.user_id, Config.AdminPermission) then
		if Config.Warnings then
			showWarning(locale("general.warn_admin_privilege_used", xPlayer.firstname, xPlayer.license))
		end
		return true
	end

	if (door.pickable or door.lockpick) and usedLockpick then return true end

	if door.authorizedJobs then
		if door.authorizedJobs[xPlayer.job.name] and xPlayer.job.rank >= door.authorizedJobs[xPlayer.job.name] then
			return true
		elseif type(door.authorizedJobs[1]) == 'string' then
			for _, job in pairs(door.authorizedJobs) do -- Support for old format
				if job == xPlayer.job.name then return true end
			end
		end
	end

	if door.authorizedGangs then
		if door.authorizedGangs[xPlayer.gang.name] and xPlayer.gang.rank >= door.authorizedGangs[xPlayer.gang.name] then
			return true
		elseif type(door.authorizedGangs[1]) == 'string' then
			for _, gang in pairs(door.authorizedGangs) do -- Support for old format
				if gang == xPlayer.gang.name then return true end
			end
		end
	end

	if door.authorizedCitizenIDs then
		if door.authorizedCitizenIDs[xPlayer.char_id] then
			return true
		elseif type(door.authorizedCitizenIDs[1]) == 'number' then
			for _, id in pairs(door.authorizedCitizenIDs) do -- Support for old format
				if id == xPlayer.char_id then return true end
			end
		end
	end

	if door.authorizedUserIds then
		if door.authorizedUserIds[xPlayer.user_id] then
			return true
		elseif type(door.authorizedUserIds[1]) == 'number' then
			for _, id in pairs(door.authorizedUserIds) do -- Support for old format
				if id == xPlayer.user_id then return true end
			end
		end
	end

	if door.authorizedRegistrations then
		if door.authorizedRegistrations[xPlayer.registration] then
			return true
		elseif type(door.authorizedRegistrations[1]) == 'string' then
			for _, id in pairs(door.authorizedRegistrations) do -- Support for old format
				if id == xPlayer.registration then return true end
			end
		end
	end

	if door.items then return checkItems(Player, door.items, door.needsAllItems, true) end

	return false
end

local function SaveDoorStates()
	SaveResourceFile(GetCurrentResourceName(), "./saves/doorstates.json", json.encode(Config.DoorStates), -1)
end

local function LoadDoorStates()
	local DoorStates = LoadResourceFile(GetCurrentResourceName(), "./saves/doorstates.json")
	if DoorStates then
		DoorStates = json.decode(DoorStates)
		if not next(DoorStates) then return end

		for key, isLocked in pairs(DoorStates) do
			if Config.DoorList[key] ~= nil then
				Config.DoorList[key].locked = isLocked
			end
		end
		Config.DoorStates = DoorStates
	end
end

-- Callbacks

lib.callback.register('doorlock:server:setupDoors', function()
	return Config.DoorList
end)

lib.callback.register('doorlock:server:checkItems', function(source, items, needsAll)
	return checkItems(source, items, needsAll, false)
end)

-- Events

RegisterNetEvent('doorlock:server:updateState',
	function(doorID, locked, src, usedLockpick, unlockAnyway, enableSounds, enableAnimation, sentSource)
		local playerId = sentSource or source
		local xPlayer = vRP.getPlayerInfo(playerId)
		if not xPlayer then return end
		if type(doorID) ~= 'number' and type(doorID) ~= 'string' then
			if Config.Warnings then
				showWarning(locale("general.warn_wrong_doorid_type", xPlayer.firstname, xPlayer.license, tostring(doorID)))
			end
			return
		end

		if type(locked) ~= 'boolean' then
			if Config.Warnings then
				showWarning(locale("general.warn_wrong_state", xPlayer.firstname, xPlayer.license, tostring(locked)))
			end
			return
		end

		if not Config.DoorList[doorID] then
			if Config.Warnings then
				showWarning(locale("general.warn_wrong_doorid", xPlayer.firstname, xPlayer.license, tostring(doorID)))
			end
			return
		end

		if not unlockAnyway and not isAuthorized(xPlayer, Config.DoorList[doorID], usedLockpick) then
			if Config.Warnings then
				showWarning(locale("general.warn_no_authorisation", xPlayer.firstname, xPlayer.license, tostring(doorID)))
			end
			return
		end

		Config.DoorList[doorID].locked = locked
		if Config.DoorStates[doorID] == nil then Config.DoorStates[doorID] = locked elseif Config.DoorStates[doorID] ~= locked then Config.DoorStates[doorID] = nil end
		TriggerClientEvent('doorlock:client:setState', -1, playerId, doorID, locked, src or false, enableSounds,
			enableAnimation)

		if not Config.DoorList[doorID].autoLock then return end
		SetTimeout(Config.DoorList[doorID].autoLock, function()
			if Config.DoorList[doorID].locked then return end
			Config.DoorList[doorID].locked = true
			if Config.DoorStates[doorID] == nil then Config.DoorStates[doorID] = locked elseif Config.DoorStates[doorID] ~= locked then Config.DoorStates[doorID] = nil end
			TriggerClientEvent('doorlock:client:setState', -1, playerId, doorID, true, src or false, enableSounds,
				enableAnimation)
		end)
	end)

local function saveNewDoor(src, data, doubleDoor)
	local xPlayer = vRP.getPlayerInfo(src)
	if not xPlayer then return end

	local configData = {}
	local jobs, gangs, cids, items, doorType, identifier
	if data.job then
		configData.authorizedJobs = { [data.job] = 0 }
		jobs = "['" .. data.job .. "'] = 0"
	end
	if data.gang then
		configData.authorizedGangs = { [data.gang] = 0 }
		gangs = "['" .. data.gang .. "'] = 0"
	end
	if data.cid then
		configData.authorizedCitizenIDs = { [data.cid] = true }
		cids = "['" .. data.cid .. "'] = true"
	end
	if data.item then
		configData.items = { [data.item] = 1 }
		items = "['" .. data.item .. "'] = 1"
	end
	configData.locked = data.locked
	configData.pickable = data.pickable
	configData.cantUnlock = data.cantunlock
	configData.hideLabel = data.hidelabel
	configData.distance = data.distance
	configData.doorType = data.doortype
	configData.doorRate = 1.0
	configData.doorLabel = data.doorlabel
	doorType = "'" .. data.doortype .. "'"
	identifier = data.id or data.configfile .. '-' .. data.dooridentifier
	if doubleDoor then
		configData.doors = {
			{
				objName = data.model[1],
				objYaw = data.heading[1],
				objCoords = data.coords[1]
			},
			{
				objName = data.model[2],
				objYaw = data.heading[2],
				objCoords = data.coords[2]
			}
		}
	else
		configData.objName = data.model
		configData.objYaw = data.heading
		configData.objCoords = data.coords
		configData.fixText = false
	end

	local path = GetResourcePath(GetCurrentResourceName())

	if data.configfile then
		local tempfile, err = io.open(
			path:gsub('//', '/') .. '/configs/' .. string.gsub(data.configfile, ".lua", "") .. '.lua', 'a+')
		if tempfile then
			tempfile:close()
			path = path:gsub('//', '/') .. '/configs/' .. string.gsub(data.configfile, ".lua", "") .. '.lua'
		else
			return error(err)
		end
	else
		path = path:gsub('//', '/') .. '/config.lua'
	end

	local file = io.open(path, 'a+')
	if not file then return end
	local label = ("\n\n-- %s %s %s\nConfig.DoorList['%s'] = {"):format(data.id or data.dooridentifier,
		locale("general.created_by"), xPlayer.name, identifier)
	file:write(label)
	for k, v in pairs(configData) do
		if k == 'authorizedJobs' or k == 'authorizedGangs' or k == 'authorizedCitizenIDs' or k == 'items' then
			local auth = jobs
			if k == 'authorizedGangs' then
				auth = gangs
			elseif k == 'authorizedCitizenIDs' then
				auth = cids
			elseif k == 'items' then
				auth = items
			end
			local str = ("\n    %s = { %s },"):format(k, auth)
			file:write(str)
		elseif k == 'doors' then
			local doors = {}
			for i = 1, 2 do
				doors[i] = ("    {objName = %s, objYaw = %s, objCoords = %s}"):format(configData.doors[i].objName,
					configData.doors[i].objYaw, configData.doors[i].objCoords)
			end
			local str = ("\n    %s = {\n    %s,\n    %s\n    },"):format(k, doors[1], doors[2])
			file:write(str)
		elseif k == 'doorType' then
			local str = ("\n    %s = %s,"):format(k, doorType)
			file:write(str)
		elseif k == 'doorLabel' then
			local str = ("\n    %s = '%s',"):format(k, v)
			file:write(str)
		else
			local str = ("\n    %s = %s,"):format(k, v)
			file:write(str)
		end
	end
	file:write("\n}")
	file:close()

	Config.DoorList[identifier] = configData
	TriggerClientEvent('doorlock:client:newDoorAdded', -1, configData, identifier, src)
end

exports('getDoor', function(id)
	return Config.DoorList[id]
end)

exports('updateDoor', function(id, data)
	local door = Config.DoorList[id]
	if not door then return end

	for k, v in pairs(data) do
		door[k] = v
	end

	TriggerClientEvent('doorlock:client:newDoorAdded', -1, door, id)
end)

RegisterNetEvent('doorlock:server:saveNewDoor', function(data, doubleDoor)
	local src = source
	if not vRP.hasPermission(vRP.getUserId(src), 'door.create') and not IsPlayerAceAllowed(src, 'command') then
		if Config.Warnings then
			showWarning(locale("general.warn_no_permission_newdoor", GetPlayerName(src),
				GetPlayerIdentifierByType(source, 'license'), src))
		end
		return
	end
	saveNewDoor(src, data, doubleDoor)
end)

AddEventHandler('onResourceStart', function(resource)
	if GetCurrentResourceName() == resource and Config.PersistentDoorStates then
		CreateThread(function()
			LoadDoorStates()
			Wait(1000)
			while true do
				Wait(Config.PersistentSaveInternal)
				SaveDoorStates()
			end
		end)
	end
end)

AddEventHandler('onResourceStop', function(resource)
	if GetCurrentResourceName() == resource and Config.PersistentDoorStates then
		SaveDoorStates()
	end
end)

RegisterNetEvent('txAdmin:events:scheduledRestart', function(eventData)
	if eventData.secondsRemaining == 60 then
		CreateThread(function()
			Wait(45000)
			SaveDoorStates()
		end)
	else
		SaveDoorStates()
	end
end)

RegisterNetEvent('doorlock:server:removeLockpick', function(type)
	if not vRP.getUserId(source) then return end
	if type == "advancedlockpick" or type == "lockpick" then
		exports.ox_inventory:RemoveItem(source, type, 1)
	end
end)

-- Commands

RegisterCommand('newdoor', function(source, args, raw)
	TriggerClientEvent('doorlock:client:addNewDoor', source)
end)

RegisterCommand('doordebug', function(source, args, raw)
	TriggerClientEvent('doorlock:client:ToggleDoorDebug', source)
end)

-- QBCore.Commands.Add('newdoor', locale("general.newdoor_command_description"), {}, false, function(source)

-- end, Config.CommandPermission)

-- QBCore.Commands.Add('', locale("general.doordebug_command_description"), {}, false, function(source)
-- 	TriggerClientEvent('doorlock:client:ToggleDoorDebug', source)
-- end, Config.CommandPermission)
