function tvRP.updatePos(x, y, z)
  local user_id = vRP.getUserId(source)
  if user_id then
    local data = vRP.getUserDataTable(user_id)
    local tmp = vRP.getUserTmpTable(user_id)
    if data and (not tmp or not tmp.home_stype) then -- don't save position if inside home slot
      data.position = vec3(x, y, z)
    end
  end
end

function tvRP.updateWeapons(weapons)
  local user_id = vRP.getUserId(source)
  if user_id then
    local data = vRP.getUserDataTable(user_id)
    if data then
      data.weapons = weapons
    end
  end
end

function tvRP.updateCustomization(customization)
  local user_id = vRP.getUserId(source)
  if user_id then
    local char_id = vRP.getPlayerTable(user_id)
    if char_id then
      vRP.setPlayerData(char_id, 'player:custom', customization)
    end
  end
end

function tvRP.updateHealth(health)
  local user_id = vRP.getUserId(source)
  if user_id then
    local data = vRP.getUserDataTable(user_id)
    if data then
      data.health = health
    end
  end
end

function vRP.createPlayer(user_id, firstname, lastname, date)
  local datatable = {
    groups = { user = true },
    health = 200,    
    weapons = {},
    position = vec3(0.0, 0.0, 0.0),
    thirst = 0,
    hunger = 0,
    stress = 0
  }
  local inventory = {}
  local money = { wallet = 5000, bank = 15000 }
  local registration = vRP.generateRegistrationNumber()
  local phone = vRP.generateRandomPhoneNumber()
  return vRP.createNewCharacter(user_id, firstname, lastname, registration, phone, date, money, inventory, datatable)
end

function vRP.setPlayerBucket(player, bucketId, population)
  SetPlayerRoutingBucket(player, bucketId)
  if bucketId ~= 0 then
    SetRoutingBucketEntityLockdownMode(bucketId, 'strict')
    SetRoutingBucketPopulationEnabled(bucketId, population)
  end
end

function vRP.login(source, user_id, char_id, firstcreation)
  if vRP.getUserId(source) ~= user_id then
    DropPlayer(source, locale('identity_check_fail'))
    return false
  end

  local character = vRP.getCharacter(char_id)
  if not character then
    DropPlayer(source, locale('character_load_fail'))
    return false
  end

  vRP.user_tables[user_id] = character
  vRP.user_tables[user_id].datatable = vRP.user_tables[user_id].datatable or {}
  vRP.user_tables[user_id].datatable['stress'] = vRP.user_tables[user_id].datatable['stress'] or 0.0
  vRP.user_tables[user_id].datatable['hunger'] = vRP.user_tables[user_id].datatable['hunger'] or 0.0
  vRP.user_tables[user_id].datatable['thirst'] = vRP.user_tables[user_id].datatable['thirst'] or 0.0
  vRP.user_tables[user_id].datatable['health'] = vRP.user_tables[user_id].datatable['health'] or 200
  vRP.user_tables[user_id].datatable['weapons'] = vRP.user_tables[user_id].datatable['weapons'] or {}
  vRP.user_tables[user_id].datatable['groups'] = vRP.user_tables[user_id].datatable['groups'] or {}
  vRP.user_tables[user_id].datatable['position'] = vRP.user_tables[user_id].datatable['position'] or cfg.fristspawn
  local custom =  vRP.getPlayerData(character.id, 'player:custom')
  vRP.user_tables[user_id].customization = custom and json.decode(custom)
  Player(source).state:set('name', ("%s %s"):format(character.firstname, character.lastname), true)
  Player(source).state:set('id', user_id)  
  TriggerEvent("vrp:login", source, user_id, char_id, firstcreation)
  return true
end

function vRP.save(user_id, x)
  if x ~= '__INTERNAL__' then return end
  if not next(vRP.user_tables[user_id] or {}) then return end
  local player = vRP.user_tables[user_id]
  if player?.user_id ~= user_id then return end
  if vRP.user_tables[user_id].isReady then
    local char_id = player?.id
    local src = vRP.getUserSource( user_id )
    local ped = GetPlayerPed( src )
    local position = GetEntityCoords( ped )
    vRP.user_tables[user_id].datatable['position'] = position
    vRP.updateCharacter(char_id, vRP.user_tables[user_id])
    -- vRP.setPlayerData(char_id, 'player:custom', player.customization)
    lib.print.info('PLAYER '.. user_id ..  ' SAVED')
  end
end

RegisterNetEvent('vrp:server:updatePlayerAppearance', function(char_id, data)
  if GetInvokingResource() then return end
  local source = source
  local user_id = vRP.getUserId(source)
  if not user_id then return end
  local xPlayer = vRP.getCharacter(char_id, false)
  if not xPlayer then return end
  if xPlayer?.id == char_id and xPlayer?.user_id == user_id then
    vRP.setPlayerData(char_id, 'player:custom', data)
  end
end)


RegisterNetEvent('vrp:player:ready', function()
  if GetInvokingResource() then return end
  local source = source
  local user_id = vRP.getUserId( source )
  if not user_id then return end
  vRP.user_tables[user_id].isReady = true  
  lib.print.info('PLAYER READY TO SAVE [ ' .. user_id .. ' ]')
  lib.print.info(json.encode(vRP.user_tables[user_id]))
end)