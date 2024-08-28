lib.locale()
cfg = module("cfg/base")

local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
local Tools = module("vrp", "lib/Tools")

vRP = {}
tvRP = {}
local players = {} -- keep track of connected players (server id)

Tunnel.bindInterface("vRP", tvRP)
vRPserver = Tunnel.getInterface("vRP")
Proxy.addInterface("vRP", tvRP)

-- functions

local user_id
function tvRP.setUserId(_user_id)
  user_id = _user_id
end

-- get user id (client-side)
function tvRP.getUserId()
  return user_id
end

function tvRP.teleport(x, y, z)
  local ped = PlayerPedId()
  tvRP.unjail() -- force unjail before a teleportation
  -- SetEntityCoords(PlayerPedId(), x+0.0001, y+0.0001, z+0.0001, 1,0,0,1)
  local entity = ped
  local vehicle = GetVehiclePedIsIn(ped, false)
  if vehicle ~= 0 then entity = vehicle end
  NetworkFadeOutEntity(entity, true, false)
  SetEntityCollision(entity, false, false)
  DoScreenFadeOut(500)
  while not IsScreenFadedOut() do Wait(0) end
  SetEntityCoordsNoOffset(entity, x + 0.001, y + 0.001, z + 0.001, false, false, true)
  local timeout = GetGameTimer() + 5000
  repeat
    local _zz = z
    local isFound, _z = GetGroundZFor_3dCoord(x, y, _zz, true)
    if not isFound and GetGameTimer() < timeout then
      _zz = _zz + 10.0
      isFound, _z = GetGroundZFor_3dCoord(x, y, _zz, true)
    else
      SetEntityCoordsNoOffset(entity, x + 0.001, y + 0.001, _z + 0.001, false, false, true)
    end
  until isFound
  DoScreenFadeIn(250)
  NetworkFadeInEntity(entity, true)
  SetEntityCollision(entity, true, true)
  vRPserver._updatePos(x, y, z)
end

---@deprecated use onesync enable in server side
function tvRP.getPosition()
  local x, y, z = table.unpack(GetEntityCoords(PlayerPedId(), true))
  return x, y, z
end

-- return false if in exterior, true if inside a building
function tvRP.isInside()
  local x, y, z = table.unpack(GetEntityCoords(PlayerPedId()))
  return not (GetInteriorAtCoords(x, y, z) == 0)
end

-- return vx,vy,vz
function tvRP.getSpeed()
  local vx, vy, vz = table.unpack(GetEntityVelocity(PlayerPedId()))
  return math.sqrt(vx * vx + vy * vy + vz * vz)
end

function tvRP.getCamDirection()
  local heading = GetGameplayCamRelativeHeading() + GetEntityHeading(PlayerPedId())
  local pitch = GetGameplayCamRelativePitch()

  local x = -math.sin(heading * math.pi / 180.0)
  local y = math.cos(heading * math.pi / 180.0)
  local z = math.sin(pitch * math.pi / 180.0)

  -- normalize
  local len = math.sqrt(x * x + y * y + z * z)
  if len ~= 0 then
    x = x / len
    y = y / len
    z = z / len
  end

  return x, y, z
end

function tvRP.addPlayer(player)
  players[player] = true
end

function tvRP.removePlayer(player)
  players[player] = nil
end

function tvRP.getPlayers()
  return players
end

function tvRP.getNearestPlayers(radius)
  local _rr = lib.getNearbyPlayers(GetEntityCoords(PlayerPedId()), radius, false)
  local rr = {}
  for _, info in next, _rr do
    rr[GetPlayerServerId(info.id)] = info
  end
  return rr
end

function tvRP.getNearestPlayer(radius)
  return lib.getClosestPlayer(GetEntityCoords(cache.ped), radius, false)
end

function tvRP.notify(msg)
  BeginTextCommandThefeedPost("STRING")
  AddTextComponentSubstringPlayerName(msg)
  EndTextCommandThefeedPostTicker(true, false)
end

function tvRP.notifyPicture(icon, iconType, sender, flash, text, sub)
  BeginTextCommandThefeedPost("STRING")
  AddTextComponentSubstringPlayerName(text)
  EndTextCommandThefeedPostMessagetext(icon, icon, flash, iconType, sender, sub)
  EndTextCommandThefeedPostTicker(false, true)
end

-- SCREEN

-- play a screen effect
-- name, see https://wiki.fivem.net/wiki/Screen_Effects
-- duration: in seconds, if -1, will play until stopScreenEffect is called
function tvRP.playScreenEffect(name, duration)
  if duration < 0 then -- loop
    AnimpostfxPlay(name, 0, true)
  else
    AnimpostfxPlay(name, 0, true)

    CreateThread(function() -- force stop the screen effect after duration+1 seconds
      Wait(math.floor((duration + 1) * 1000))
      AnimpostfxStop(name)
    end)
  end
end

-- stop a screen effect
-- name, see https://wiki.fivem.net/wiki/Screen_Effects
function tvRP.stopScreenEffect(name)
  AnimpostfxStop(name)
end

-- ANIM

-- animations dict and names: http://docs.ragepluginhook.net/html/62951c37-a440-478c-b389-c471230ddfc5.htm

local anims = {}
local anim_ids = Tools.newIDGenerator()

-- play animation (new version)
-- upper: true, only upper body, false, full animation
-- seq: list of animations as {dict,anim_name,loops} (loops is the number of loops, default 1) or a task def (properties: task, play_exit)
-- looping: if true, will infinitely loop the first element of the sequence until stopAnim is called
function tvRP.playAnim(upper, seq, looping)
  local ped = PlayerPedId()
  if seq.task then                                        -- is a task (cf https://github.com/ImagicTheCat/vRP/pull/118)
    tvRP.stopAnim(true)
    if seq.task == "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER" then -- special case, sit in a chair
      local pos = GetEntityCoords(ped)
      TaskStartScenarioAtPosition(ped, seq.task, pos.x, pos.y, pos.z - 1, GetEntityHeading(ped), 0, false, false)
    else
      TaskStartScenarioInPlace(ped, seq.task, 0, not seq.play_exit)
    end
  else -- a regular animation sequence
    tvRP.stopAnim(upper)

    local flags = 0
    if upper then flags = flags + 48 end
    if looping then flags = flags + 1 end

    CreateThread(function()
      -- prepare unique id to stop sequence when needed
      local id = anim_ids:gen()
      anims[id] = true

      for k, v in pairs(seq) do
        local dict = v[1]
        local name = v[2]
        local loops = v[3] or 1

        for i = 1, loops do
          if anims[id] then -- check animation working
            local first = (k == 1 and i == 1)
            local last = (k == #seq and i == loops)

            -- request anim dict
            RequestAnimDict(dict)
            local timeout = GetGameTimer() + 3000
            while not HasAnimDictLoaded(dict) and GetGameTimer() < timeout do Wait(0) end

            -- play anim
            if HasAnimDictLoaded(dict) and anims[id] then
              local inspeed = 8.0001
              local outspeed = -8.0001
              if not first then inspeed = 2.0001 end
              if not last then outspeed = 2.0001 end
              TaskPlayAnim(ped, dict, name, inspeed, outspeed, -1, flags, 0, false, false, false)

              Wait(0)

              while GetEntityAnimCurrentTime(ped, dict, name) <= 0.95 and IsEntityPlayingAnim(ped, dict, name, 3) do
                Wait(0)
              end
            end
          end
        end
      end

      -- free id
      anim_ids:free(id)
      anims[id] = nil
    end)
  end
end

-- stop animation (new version)
-- upper: true, stop the upper animation, false, stop full animations
function tvRP.stopAnim(upper, force)
  anims = {} -- stop all sequences

  local ped = PlayerPedId()
  if force then
    ClearPedTasksImmediately(ped)
  else
    if upper then
      ClearPedSecondaryTask(ped)
    else
      ClearPedTasks(ped)
    end
  end
end

-- RAGDOLL
local ragdoll = false

local function startRangdollThread()
  CreateThread(function()
    while ragdoll do
      SetPedToRagdoll(PlayerPedId(), 1000, 1000, 0, false, false, false)
      Wait(10)
    end
  end)
end

-- set player ragdoll flag (true or false)
function tvRP.setRagdoll(flag)
  if ragdoll == flag then return end
  ragdoll = flag
  if ragdoll then
    startRangdollThread()
  end
end

function tvRP.setMovement(dict)
  if dict then
    if not HasAnimSetLoaded(dict) then
      RequestAnimSet(dict)
      local timeout = GetGameTimer() + 2000
      while not HasAnimSetLoaded(dict) and GetGameTimer() < timeout do Wait(0) end
    end
    if HasAnimSetLoaded(dict) then
      SetPedMovementClipset(PlayerPedId(), dict, 0.0)
      RemoveAnimSet(dict)
    end
  else
    ResetPedMovementClipset(PlayerPedId(), 0.0)
  end
end

-- events

AddEventHandler("playerSpawned", function()
  --temos que desabiltar o autospawn aqui ou vai bugar muita coisa, vamos deixar o vRP gerenciar.
  if GetResourceState('spawnmanager') == 'started' then
    exports.spawnmanager:setAutoSpawn(false)   
  end

  -- TriggerServerEvent("vRPcli:playerSpawned")
end)

function vRP.setPedFlags(value)
  SetPedDropsWeaponsWhenDead(value, false)
  SetPedConfigFlag(value, 422, true)
  SetPedConfigFlag(value, 35, false)
  SetPedConfigFlag(value, 128, false)
  SetPedConfigFlag(value, 184, true)
  SetPedConfigFlag(value, 229, true)
end


AddStateBagChangeHandler('isLoggedIn', nil, function (bagName, key, value, reserved)
  print(bagName, key, value, reserved)  
end)
