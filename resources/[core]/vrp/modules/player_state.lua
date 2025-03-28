function tvRP.updateCustomization(customization)
  local user_id = vRP.getUserId(source)
  if user_id then
    local playerTable = vRP.getPlayerTable(user_id)
    if playerTable?.id then
      -- vRP.setPlayerData(playerTable.id, 'player:custom', customization)
      MySQL.update.await('UPDATE players SET skin = ? WHERE id = ?', {json.encode(customization), playerTable.id})
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

function vRP.createPlayer(user_id, firstname, lastname, gender, date)
  local datatable = {
    groups = {},
    health = 200,
    weapons = {},
    position = nil,
    thirst = 0,
    hunger = 0,
    stress = 0
  }
  local inventory = {}
  local money = { cash = vRPconfig?.money_type?.cash or 1000, bank = vRPconfig?.money_type?.bank or 1000 }
  local registration = vRP.generateRegistrationNumber()
  local phone = vRP.generateRandomPhoneNumber()
  return vRP.createNewCharacter(user_id, firstname, lastname, gender, registration, phone, date, money, inventory, datatable)
end

function vRP.setPlayerBucket(player, bucketId, population)
  SetPlayerRoutingBucket(player, bucketId)
  if bucketId ~= 0 then
    SetRoutingBucketEntityLockdownMode(bucketId, 'strict')
    SetRoutingBucketPopulationEnabled(bucketId, population)
  end
end

function vRP.getWeapons(user_id)
  return vRP.getUserDataTable(user_id)?.weapons or {}
end

function vRP.giveWeapons(user_id, weapons, clear_before)
  local src = vRP.getUserSource(user_id)
  if not src then return end
  local datatable = vRP.getUserDataTable(user_id)
  local ped = GetPlayerPed(src)
  if clear_before then
    datatable.weapons = {}
    RemoveAllPedWeapons(ped, true)
  end

  for weapon, prop in next, weapons or {} do
    local hash = joaat(weapon)
    local ammo = prop.ammo or 0
    if ammo > 150 then ammo = 150 end
    if ammo < 0 then ammo = 0 end
    GiveWeaponToPed(ped, hash, ammo, false, false)
    for _, wcomp in next, prop?.components or {} do
      GiveWeaponComponentToPed(ped, hash, joaat(wcomp))
    end

    if prop?.liveries and #prop.liveries > 0 then
      TriggerClientEvent('vrp:client:weapon_sync', src, 'LIVERY', weapon, prop.liveries)
    end

    if prop?.tint then
      TriggerClientEvent('vrp:client:weapon_sync', src, 'TINT', weapon, prop?.tint)
    end

    datatable.weapons[weapon] = prop
  end

  TriggerClientEvent('vRP:SetPlayerMetadata', src, datatable)
end

function vRP.replaceWeapons(user_id, weapons)
  local old = vRP.getWeapons(user_id)
  vRP.giveWeapons(user_id, weapons, true)
  return old
end

function vRP.setArmour(user_id, armour)
  if armour > 100 then armour = 100 end
  if armour < 0 then armour = 0 end
  local src = vRP.getUserSource(user_id)
  if not src then return end
  local ped = GetPlayerPed(src)
  SetPedArmour(ped, armour)
end

function vRP.getPlayerId( user_id)
  return vRP.getPlayerTable(user_id)?.id  
end

function vRP.getCharId( src )
  local id = Player(src).state.char_id
  if id then return id end
  local user_id = vRP.getUserId( src )
  return vRP.getPlayerId( user_id)
end

function vRP.getUserIdByPlayerId( char_id )
  local id = MySQL.scalar.await('SELECT user_id	FROM players WHERE id = ?', {char_id})

  return id and tonumber(id) or nil
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
  if firstcreation then
    vRP.user_tables[user_id].datatable['position'] = nil
  else
    vRP.user_tables[user_id].datatable['position'] = vRP.user_tables[user_id].datatable['position'] or cfg.fristspawn 
  end

  -- local custom = vRP.getPlayerData(character.id, 'player:custom')
  -- vRP.user_tables[user_id].customization = custom and json.decode(custom)
  Player(source).state:set('name', ("%s %s"):format(character.firstname, character.lastname), true)
  Player(source).state:set('id', user_id)
  Player(source).state:set('char_id', character.id, true)

  vRP.character_source[character.id] = source
  vRP.character_user[character.id] = user_id
  vRP.source_character[source] = char_id

  TriggerEvent("vrp:login", source, user_id, char_id, firstcreation)
  TriggerClientEvent('vRP:SetPlayerData', source, vRP.getPlayerInfo(source))
  vRPclient._setMaxHealth(source, 200)
  Wait(0)
  vRPclient._setHealth(source, vRP.user_tables[user_id].datatable['health'])
  return true
end


function vRP.getCharaterIdBySource( src )
  return vRP.source_character[src]
end

function vRP.getUserIdByCharacterId( char_id )
  return vRP.character_user[char_id]
end

function vRP.getSourceByCharacterId( char_id )
  return vRP.character_source[char_id]
end

function vRP.save(user_id, x)
  if x ~= '__INTERNAL__' then return end
  if not next(vRP.user_tables[user_id] or {}) then return end
  local player = vRP.user_tables[user_id]
  if player?.user_id ~= user_id then return end
  -- if vRP.user_tables[user_id].isReady then
  local char_id = player?.id
  local src = vRP.getUserSource(user_id)
  local ped = GetPlayerPed(src)
  local position = GetEntityCoords(ped)
  vRP.user_tables[user_id].datatable['position'] = position
  vRP.updateCharacter(char_id, vRP.user_tables[user_id])  
end

RegisterNetEvent('vrp:server:updatePlayerAppearance', function(char_id, data)
  if GetInvokingResource() then return end
  local source = source
  local user_id = vRP.getUserId(source)
  if not user_id then return end
  local xPlayer = vRP.getCharacter(char_id, false)
  if not xPlayer then return end
  MySQL.update.await('UPDATE players SET skin = ? WHERE id = ?', { json.encode(data), char_id})
end)


RegisterNetEvent('vrp:player:ready', function(state)
  if GetInvokingResource() then return end
  local source = source
  local user_id = vRP.getUserId(source)
  if not user_id then return end
  if vRP.user_tables[user_id] then
    vRP.user_tables[user_id].isReady = state
    if state then
      if GetPlayerRoutingBucket( source ) ~= 0 then
        SetPlayerRoutingBucket( source, 0)
      end
      lib.print.info('PLAYER READY TO SAVE [ ' .. user_id .. ' ]')
    end
  end
end)