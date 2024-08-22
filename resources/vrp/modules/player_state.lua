function tvRP.updatePos(x,y,z)
  local user_id = vRP.getUserId(source)
  if user_id then
    local data = vRP.getUserDataTable(user_id)
    local tmp = vRP.getUserTmpTable(user_id)
    if data and (not tmp or not tmp.home_stype) then -- don't save position if inside home slot
      data.position = {x = tonumber(x), y = tonumber(y), z = tonumber(z)}
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
    local data = vRP.getUserDataTable(user_id)
    if data then
      data.customization = customization
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
      customization = {},
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
  TriggerEvent("vrp:login", source, user_id, char_id, firstcreation)
  return true
end


RegisterNetEvent('vrp:server:updatePlayerAppearance', function (char_id, data)
  if GetInvokingResource() then return end
  print('okok')
  local source = source
  local user_id = vRP.getUserId(source)

  lib.print.info(user_id, char_id)

  if not user_id then return end

  local xPlayer = vRP.getCharacter( char_id, false )

  lib.print.info(json.encode(xPlayer))

  if not xPlayer then return end
  if xPlayer?.id == char_id and xPlayer?.user_id == user_id then
    vRP.setPlayerData(char_id, 'player:custom', data)
  end
end)