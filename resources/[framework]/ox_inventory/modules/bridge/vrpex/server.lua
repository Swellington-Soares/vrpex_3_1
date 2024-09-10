lib.load('@vrp.lib.utils', _G)
local Proxy = lib.require('@vrp.lib.Proxy')
local vRP = Proxy.getInterface('vRP')

local Inventory = require 'modules.inventory.server'

local function reorderGroups(groups)
	local rr = {}
	for k, v in next, groups or {} do
		if type(v) == "table" and v?.rank then
			rr[k] = v.rank
		end
	end
	return rr
end

local function setCharacterInventory(source, character)
	if not character then return end
	local player = {
		identifier = character.id,
		name = ("%s %s"):format(character.firstname, character.lastname),
		user_id = character.user_id,
		license = character.license,
		dateofbirth = os.date("%d/%m/%Y", character.birth_date // 1000),
		groups = reorderGroups(character?.datatable?.groups),
		sex = character.gender or 'M',
		source = source
	}
	server.setPlayerInventory(player)
	
	Inventory.SetItem(source, "money", character?.money?.cash or 0)
end

AddEventHandler('vrp:login', function(source, user_id)
	setCharacterInventory(source, vRP.getPlayerTable(user_id))
end)

SetTimeout(500, function()
    
    for k, v in pairs(vRP.getUsers()) do		
		setCharacterInventory(v, vRP.getPlayerTable(k))        
    end
end)


AddEventHandler('vRP:PlayerMoneyUpdate', function (user_id, amount, moneytype)
	print('vRP:PlayerMoneyUpdate', user_id, amount, moneytype)
	if moneytype ~= 'cash' then return end
	local src = vRP.getUserSource(user_id)
	if not src then return end
	Inventory.SetItem(src, 'money', amount)
end)

--@diagnostic disable-next-line: duplicate-set-field
function server.setPlayerData(player)
	lib.print.info('setPlayerData', player)
	local user_id = vRP.getUserId(player.source)
	if user_id then
		local groups = vRP.getUserGroups(user_id)
		player.groups = reorderGroups(groups)
	end
	return player
end

---@diagnostic disable-next-line: duplicate-set-field
function server.hasLicense(inv, name)
	-- local player = Ox.GetPlayer(inv.id)

	-- if not player then return end

	-- return player.getLicense(name)
	return false
end

---@diagnostic disable-next-line: duplicate-set-field
function server.buyLicense(inv, license)
	-- local player = Ox.GetPlayer(inv.id)

	-- if not player then return end


	-- if player.getLicense(license.name) then
	-- 	return false, 'already_have'
	-- elseif Inventory.GetItemCount(inv, 'money') < license.price then
	-- 	return false, 'can_not_afford'
	-- end

	-- Inventory.RemoveItem(inv, 'money', license.price)
	-- player.addLicense(license.name)

	-- return true, 'have_purchased'
	return false
end

---@diagnostic disable-next-line: duplicate-set-field
function server.isPlayerBoss(playerId, group, grade)
	return vRP.isGroupGradeBoss(group, grade)
end

---@param entityId number
---@return number | string
---@diagnostic disable-next-line: duplicate-set-field
function server.getOwnedVehicleId(entityId)
	return GetVehicleNumberPlateText(entityId)
end

---@diagnostic disable-next-line: duplicate-set-field
function server.syncInventory(inv)
	local accounts = Inventory.GetAccountItemCounts(inv)
	if not accounts then return end
	for account, amount in pairs(accounts) do
		account = account == 'money' and 'cash' or account
		if vRP.getMoney(inv.player.user_id, account) ~= amount then
			lib.print.info('Money Sync', account, amount)
			vRP.setMoney(inv.player.user_id, amount, account, ('Sync %s with inventory'):format(account), false)
		end
	end
end


AddStateBagChangeHandler('loadInventory', nil, function(bagName, _, value)
    if not value then return end
    local plySrc = GetPlayerFromStateBagName(bagName)
	print('loadInventory', bagName, _, value)
    -- if not plySrc then return end
    -- setupPlayer(QBX:GetPlayer(plySrc).PlayerData)
end)

-- AddEventHandler('vRP:playerLeave', function(_, source)
-- 	server.playerDropped(source)
-- end)

---@diagnostic disable-next-line: param-type-mismatch
AddStateBagChangeHandler('isLoggedIn', nil, function(bagName, _, value)
	local player = GetPlayerFromStateBagName(bagName)
	if not player then return end
	if not value then
		server.playerDropped(player)
	end
end)
