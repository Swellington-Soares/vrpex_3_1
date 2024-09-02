local cfg = module("cfg/base")

-- api

function vRP.getHunger(user_id)
  local data = vRP.getUserDataTable(user_id)
  if data then
    return data.hunger
  end

  return 0
end

function vRP.getThirst(user_id)
  local data = vRP.getUserDataTable(user_id)
  if data then
    return data.thirst
  end

  return 0
end

function vRP.setHunger(user_id, value)
  local data = vRP.getUserDataTable(user_id)
  if data then
    data.hunger = value
    if data.hunger < 0 then
      data.hunger = 0
    elseif data.hunger > 100 then
      data.hunger = 100
    end

    local src = vRP.getUserSource(user_id)
    Player(src).state:set('hunger', data.hunger, true)
  end
end

function vRP.setThirst(user_id, value)
  local data = vRP.getUserDataTable(user_id)
  if data then
    data.thirst = value
    if data.thirst < 0 then
      data.thirst = 0
    elseif data.thirst > 100 then
      data.thirst = 100
    end

    local src = vRP.getUserSource(user_id)
    Player(src).state:set('thirst', data.thirst, true)
  end
end

function vRP.varyHunger(user_id, variation)
  local data = vRP.getUserDataTable(user_id)
  if data then
    data.hunger = data.hunger + variation


    -- apply overflow as damage
    local overflow = data.hunger - 100
    if overflow > 0 then
      vRPclient._varyHealth(vRP.getUserSource(user_id), -overflow * cfg.overflow_damage_factor)
    end

    if data.hunger < 0 then
      data.hunger = 0
    elseif data.hunger > 100 then
      data.hunger = 100
    end

    local src = vRP.getUserSource(user_id)
    Player(src).state:set('hunger', data.hunger, true)
  end
end

function vRP.varyThirst(user_id, variation)
  local data = vRP.getUserDataTable(user_id)
  if data then
    data.thirst = data.thirst + variation

    -- apply overflow as damage
    local overflow = data.thirst - 100
    if overflow > 0 then
      vRPclient._varyHealth(vRP.getUserSource(user_id), -overflow * cfg.overflow_damage_factor)
    end

    if data.thirst < 0 then
      data.thirst = 0
    elseif data.thirst > 100 then
      data.thirst = 100
    end

    local src = vRP.getUserSource(user_id)
    Player(src).state:set('thirst', data.hunger, true)
  end
end

-- tunnel api (expose some functions to clients)

function tvRP.varyHunger(variation)
  local user_id = vRP.getUserId(source)
  if user_id then
    vRP.varyHunger(user_id, variation)
  end
end

function tvRP.varyThirst(variation)
  local user_id = vRP.getUserId(source)
  if user_id then
    vRP.varyThirst(user_id, variation)
  end
end


function tvRP.notifyDeath(data)

end

function tvRP.notifyAfterDeath()
  local source = source
  if cfg?.clear_inventory_on_death then
    exports.ox_inventory:ClearInventory( source, {
      'identification',
      'mastercard'
    })
  end
end

-- tasks

-- hunger/thirst increase
function task_update()
  for k, v in pairs(vRP.users) do
    vRP.varyHunger(v, cfg.hunger_per_minute)
    vRP.varyThirst(v, cfg.thirst_per_minute)
  end

  SetTimeout(60000, task_update)
end

async(function()
  if cfg.survival then
    task_update()
  end
end)

-- handlers

-- -- init values
-- AddEventHandler("vRP:playerJoin", function(user_id, source, name, last_login)
--   local data = vRP.getUserDataTable(user_id)
--   if data.hunger == nil then
--     data.hunger = 0
--     data.thirst = 0
--   end
-- end)

-- -- add survival progress bars on spawn
-- AddEventHandler("vRP:playerSpawn", function(user_id, source, first_spawn)
--   local data = vRP.getUserDataTable(user_id)
--   vRPclient._setPolice(source, cfg.police)
--   vRPclient._setFriendlyFire(source, cfg.pvp)
--   vRP.setHunger(user_id, data.hunger)
--   vRP.setThirst(user_id, data.thirst)
-- end)
