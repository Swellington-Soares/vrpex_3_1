local handcuffed = false
-- set player as cop (true or false)
function tvRP.setCop(flag)
  SetPedAsCop(PlayerPedId(), flag)
  LocalPlayer.state.cop = flag
end

function tvRP.isHandcuffed()
  return handcuffed
end

-- (experimental, based on experimental getNearestVehicle)
function tvRP.putInNearestVehicleAsPassenger(radius)
  local veh = tvRP.getNearestVehicle(radius)

  if IsEntityAVehicle(veh) then
    for i = 1, math.max(GetVehicleMaxNumberOfPassengers(veh), 3) do
      if IsVehicleSeatFree(veh, i) then
        SetPedIntoVehicle(PlayerPedId(), veh, i)
        return true
      end
    end
  end

  return false
end

function tvRP.putInNetVehicleAsPassenger(net_veh)
  local veh = NetworkGetEntityFromNetworkId(net_veh)
  if IsEntityAVehicle(veh) then
    for i = 1, GetVehicleMaxNumberOfPassengers(veh) do
      if IsVehicleSeatFree(veh, i) then
        SetPedIntoVehicle(PlayerPedId(), veh, i)
        return true
      end
    end
  end
end

function tvRP.putInVehiclePositionAsPassenger(x, y, z)
  local veh = tvRP.getVehicleAtPosition(x, y, z)
  if IsEntityAVehicle(veh) then
    for i = 1, GetVehicleMaxNumberOfPassengers(veh) do
      if IsVehicleSeatFree(veh, i) then
        SetPedIntoVehicle(PlayerPedId(), veh, i)
        return true
      end
    end
  end
end

-- FOLLOW

local follow_player

-- follow another player
-- player: nil to disable
function tvRP.followPlayer(player)
  follow_player = player

  if not player then -- unfollow
    ClearPedTasks(PlayerPedId())
  end
end

-- return player or nil if not following anyone
function tvRP.getFollowedPlayer()
  return follow_player
end

-- follow thread
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(5000)
    if follow_player then
      local tplayer = GetPlayerFromServerId(follow_player)
      local ped = PlayerPedId()
      if NetworkIsPlayerConnected(tplayer) then
        local tped = GetPlayerPed(tplayer)
        TaskGoToEntity(ped, tped, -1, 1.0, 10.0, 1073741824.0, 0)
        SetPedKeepTask(ped, true)
      end
    end
  end
end)

-- JAIL

local jail = nil

-- jail the player in a no-top no-bottom cylinder
function tvRP.jail(x, y, z, radius)
  tvRP.teleport(x, y, z) -- teleport to center
  jail = { x + 0.0001, y + 0.0001, z + 0.0001, radius + 0.0001 }
end

-- unjail the player
function tvRP.unjail()
  jail = nil
end

function tvRP.isJailed()
  return jail ~= nil
end

local handcuffThreadStarted = false

local function StartHandcuffThread()
  if not handcuffThreadStarted then
    handcuffThreadStarted = true
    CreateThread(function()
      lib.requestAnimDict('mp_arresting')
      while handcuffed do
        if not IsEntityPlayingAnim(cache.ped, "mp_arresting", "idle", 3) then
          TaskPlayAnim(cache.ped, "mp_arresting", "idle", 8.0, -8.0, -1, 0, 0.0, false, false, false)
        end
        Wait(2000)
      end
      RemoveAnimDict('mp_arresting')
      handcuffThreadStarted = false
    end)
  end
end

local beforeCuffDrawable
AddStateBagChangeHandler('handcuffed', ('player:%s'):format(cache.serverId), function(_, _, value)  
  handcuffed = value
  LocalPlayer.state.disableControls = value
  SetEnableHandcuffs(cache.ped, value)
  SetEnableBoundAnkles(cache.ped, value)
  SetPedConfigFlag(cache.ped, 48, value)
  SetPedConfigFlag(cache.ped, 120, value)
  SetPedConfigFlag(cache.ped, 156, not value)
  SetPedConfigFlag(cache.ped, 186, value)
  SetPedConfigFlag(cache.ped, 188, value)
  SetPedConfigFlag(cache.ped, 188, value)
  LocalPlayer.state.canEmote = not value
  if value then
    
    beforeCuffDrawable = { GetPedDrawableVariation(cache.ped, 7), GetPedTextureVariation(cache.ped, 7) }
    local model = GetEntityModel(cache.ped)
    if model == `mp_m_freemode_01` or model == `mp_f_freemode_01` then
      SetPedComponentVariation(cache.ped, 7, model == `mp_m_freemode_01` and 41 or 25, 0, 0)
    end
    
    SetEnableHandcuffs(PlayerPedId(), value)
    tvRP.playAnim(true, { { "mp_arresting", "idle", 1 } }, true)
    if not handcuffThreadStarted then
      StartHandcuffThread()
    end
  else    
    tvRP.stopAnim(true)
    SetPedStealthMovement(PlayerPedId(), false, "")
    UncuffPed(cache.ped)
    if beforeCuffDrawable then
      SetPedComponentVariation(cache.ped, 7, beforeCuffDrawable[1], beforeCuffDrawable[2], 0)
      beforeCuffDrawable = nil
    end
  end
end)
