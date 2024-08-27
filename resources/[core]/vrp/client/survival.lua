-- api
local scaleform <const> = "MP_BIG_MESSAGE_FREEMODE"
local COMA_TEXT <const> = locale('wait_help')
local RESPAWN_TEXT <const> = locale('press_E_to_respawn')


---@type CKeybind
local comaKey

--#DEATH HOSPITAL SCENE ---------------------------------------------------------

local HOSPITAL_COORD <const> = {
  HOSPITAL_RH = {
    coord = vec3(-447.2036, -342.8395, 34.5020),
    rot = vec3(0.0000, 0.0000, 109.1352),
    animDict = "respawn@hospital@rockford",
    animName = "rockford",
    animCam = "rockford_cam",
  },
  HOSPITAL_SC = {
    coord = vec3(342.7344, -1397.8510, 32.5092),
    rot = vec3(0.0, 0.0, 62.5160),
    animDict = 'respawn@hospital@south_central',
    animName = 'south_central',
    animCam = 'south_central_cam'
  },
  HOSPITAL_DT = {
    coord = vec3(357.3475, -585.6215, 28.8310),
    rot = vec3(0.0000, 0.0000, -95.0926),
    animDict = 'respawn@hospital@downtown',
    animName = 'downtown',
    animCam = 'downtown_cam'
  },
  HOSPITAL_SS = {
    coord = vec3(1837.655, 3673.500, 34.308),
    rot = vec3(0,0,-146.160),
    animDict = 'respawn@hospital@sandy_shores',
    animName = 'sandy_shores',
    animCam = 'sandy_shores_cam'
  },
  HOSPITAL_PB = {
    coord = vec3(-244.6081, 6324.9629, 32.4260),
    rot = vec3(0, 0, -57.7613),
    animDict = 'respawn@hospital@paleto_bay',
    animName = 'paleto_bay',
    animCam = 'paleto_bay_cam'
  },
}

local function GetNearbyHospital(pos)
  local k
  local min = 99999
  for id, info in next, HOSPITAL_COORD do
    local distance = #(pos - info.coord)
    if min > distance then
      min = distance
      k = id
    end
  end
  lib.print.info(k)
  return HOSPITAL_COORD[k]
end


local function RunDeathScene()
  if not IsScreenFadedOut() then DoScreenFadeOut(0) end
  local fRESPAWN_CUTSCENE_RADIUS <const> = 15.0
  local ped = PlayerPedId()
  local h = GetNearbyHospital(GetEntityCoords(ped))
  SetPlayerControl(cache.playerId, false, 0)
  SetEntityCoords(ped, h.coord.x, h.coord.y, h.coord.z, false, true, false, true)
  -- SetFocusPosAndVel(h.coord.x, h.coord.y, h.coord.z, 0.0, 0.0, 0.0)
  FreezeEntityPosition(ped, true)
  SetEntityInvincible(ped, true)
  -- SetEntityCollision(ped, false, false)
  RemoveParticleFxInRange(h.coord.x, h.coord.y, h.coord.z, fRESPAWN_CUTSCENE_RADIUS)
  RemoveDecalsInRange(h.coord.x, h.coord.y, h.coord.z, fRESPAWN_CUTSCENE_RADIUS)
  ClearArea(h.coord.x, h.coord.y, h.coord.z, 5.0, true, false, false, false)
  Wait(1000)
  tvRP.revivePlayer()
  ped = PlayerPedId()
  local dict = lib.requestAnimDict(h.animDict)
  SetEntityHeading(ped, h.rot.z)
  SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
  ClearPedTasksImmediately(ped)
  Wait(3000)

  if not IsScreenFadedIn() or not IsScreenFadingIn() then DoScreenFadeIn(0) end
  FreezeEntityPosition(ped, false)
  local sceneId = CreateSynchronizedScene(h.coord.x + 0.5, h.coord.y + 0.5, h.coord.z, h.rot.x, h.rot.y, h.rot.z, 2)
  local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
  SetSynchronizedSceneLooped(sceneId, false)
  SetSynchronizedSceneHoldLastFrame(sceneId, false)
  TaskSynchronizedScene(ped, sceneId, h.animDict, h.animName, 1000.0, -8.4, 0, 0x447a0000, 0)
  SetForceFootstepUpdate(ped, true)
  PlaySynchronizedCamAnim(cam, sceneId, h.animCam, dict)
  Wait(0)

  while GetSynchronizedScenePhase(sceneId) < 0.99 do
    Wait(0)
    HideHudAndRadarThisFrame()
  end
  DetachSynchronizedScene(sceneId)
  SetCamActive(cam, false)
  DestroyCam(cam, true)
  RemoveAnimDict(dict)
  RenderScriptCams(false, false, 0, true, true)
  SetPlayerControl(cache.playerId, true, 0)
  SetEntityInvincible(ped, false)
  Wait(0)
end



local function func_92(sParam0)
  BeginTextCommandScaleformString('STRING')
  AddTextComponentSubstringPlayerName(sParam0)
  EndTextCommandScaleformString()
end

local function DeathScreen()
  local p = promise.new()
  CreateThread(function()
    local id = 0
    local timeout = GetGameTimer() + 2000
    local scale
    while true do
      if id == 0 then
        id = 1
        scale = RequestScaleformMovie(scaleform)
      end

      if id == 1 then
        if GetGameTimer() > timeout or HasScaleformMovieFilenameLoaded(scaleform) then
          BeginScaleformMovieMethod(scale, "SHOW_SHARD_WASTED_MP_MESSAGE")
          func_92('~r~' .. GetLabelText('RESPAWN_W_MP'))
          EndScaleformMovieMethod()
          timeout = GetGameTimer() + 8000
          AnimpostfxPlay('DeathFailOut', 0, false)
          PlaySoundFrontend(-1, "Bed", "WastedSounds", true)
          ShakeGameplayCam("DEATH_FAIL_IN_EFFECT_SHAKE", 1.0)
          id = 2
        end
        Wait(500)
        PlaySoundFrontend(-1, "TextHit", "WastedSounds", true)
      end

      if id == 2 then
        if HasScaleformMovieFilenameLoaded(scaleform) then
          if GetGameTimer() < timeout then
            DrawScaleformMovieFullscreen(scale, 255, 255, 255, 255, 0)
          elseif GetGameTimer() < timeout + 100 then
            BeginScaleformMovieMethod(scale, "TRANSITION_OUT")
            EndScaleformMovieMethod()
            timeout = timeout - 100
          elseif GetGameTimer() < timeout + 500 then
            DrawScaleformMovieFullscreen(scale, 255, 255, 255, 255, 0)
          else
            id = 3
          end
        end
      end

      if id == 3 then
        if HasScaleformMovieFilenameLoaded(scaleform) then
          SetScaleformMovieAsNoLongerNeeded(scale)
          StopScreenEffect("DeathFailOut")
        end
        break
      end

      Wait(0)
    end
    p:resolve(true)
  end)
  return p
end

function tvRP.varyHealth(variation)
  local ped = PlayerPedId()

  local n = math.floor(GetEntityHealth(ped) + variation)
  SetEntityHealth(ped, n)
end

function tvRP.getHealth()
  return GetEntityHealth(PlayerPedId())
end

function tvRP.setHealth(health)
  local n = math.floor(health)
  SetEntityHealth(PlayerPedId(), n)
end

function tvRP.setFriendlyFire(flag)
  NetworkSetFriendlyFireOption(flag)
  SetCanAttackFriendly(PlayerPedId(), flag, flag)
end

function tvRP.setPolice(flag)
  local player = PlayerId()
  SetPoliceIgnorePlayer(player, not flag)
  SetDispatchCopsForPlayer(player, flag)
end

function tvRP.isNoclip()
  return false
end

-- impact thirst and hunger when the player is running (every 5 seconds)
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(5000)
    if IsPlayerPlaying(PlayerId()) then
      local ped = PlayerPedId()

      -- variations for one minute
      local vthirst = 0
      local vhunger = 0

      -- on foot, increase thirst/hunger in function of velocity
      if IsPedOnFoot(ped) and not tvRP.isNoclip() then
        local factor = math.min(tvRP.getSpeed(), 10)

        vthirst = vthirst + 1 * factor
        vhunger = vhunger + 0.5 * factor
      end

      -- in melee combat, increase
      if IsPedInMeleeCombat(ped) then
        vthirst = vthirst + 10
        vhunger = vhunger + 5
      end

      -- injured, hurt, increase
      if IsPedHurt(ped) or IsPedInjured(ped) then
        vthirst = vthirst + 2
        vhunger = vhunger + 1
      end

      -- do variation
      if vthirst ~= 0 then
        vRPserver._varyThirst(vthirst / 12.0)
      end

      if vhunger ~= 0 then
        vRPserver._varyHunger(vhunger / 12.0)
      end
    end
  end
end)

-- COMA SYSTEM

local in_coma = false
local COMA_MAX <const> = cfg.coma_duration * 60
local coma_left = COMA_MAX


function tvRP.revivePlayer()
  local ped = PlayerPedId()
  local pos = GetEntityCoords(ped)
  if IsEntityDead(ped) then
    in_coma = false
    coma_left = COMA_MAX
    comaKey:disable(true)
    lib.hideTextUI()

    FreezeEntityPosition(ped, false)
    SetPlayerControl(cache.playerId, true, 0)
    NetworkResurrectLocalPlayer(pos.x, pos.y, pos.z, GetEntityHeading(ped), 0, false)
    SetEntityHealth(ped, 200)
    ClearPedBloodDamage(ped)
    ResetPedMovementClipset(ped, 0.0)
    ResetPedStrafeClipset(ped)
    ResetPedWeaponMovementClipset(ped)
    SetPedCanBeDraggedOut(ped, true)
    SetPedCanBeKnockedOffVehicle(ped, 0)
    SetPedCanSmashGlass(ped, true, true)
    SetPedDiesInSinkingVehicle(ped, true)
    SetPedMaxTimeUnderwater(ped, 1)
    SetPedCanSwitchWeapon(ped, true)
    ResetPedInVehicleContext(ped)
    ClearPedDriveByClipsetOverride(ped)
    SetPedInfiniteAmmoClip(ped, false)
    SetPedCanPlayAmbientAnims(ped, true)
    SetPedIsDrunk(ped, false)
    SetPlayerForcedAim(ped, false)
  end
end

function tvRP.isInComa()
  return in_coma
end

-- kill the player if in coma
function tvRP.killComa()
  if in_coma then
    coma_left = 0
  end
end

Citizen.CreateThread(function() -- coma decrease thread
  while true do
    Citizen.Wait(1000)
    if in_coma then
      coma_left = coma_left - 1
    end
  end
end)




local function KillPlayer()
  lib.hideContext()
  lib.hideRadial()
  PauseDeathArrestRestart(true)
  coma_left = COMA_MAX
  in_coma = true
  SetPlayerControl(PlayerId(), false, 0)
  tvRP.ejectVehicle()
  comaKey:disable(true)
  Citizen.Await(DeathScreen())
  vRPserver._updateHealth(0)
  CreateThread(function()
    while in_coma do
      FreezeEntityPosition(cache.ped, true)
      local isTextOpen, text = lib.isTextUIOpen()
      if coma_left > 0 then
        lib.showTextUI(COMA_TEXT .. ' [' .. coma_left .. ']', {
          icon = 'skull',
          position = 'bottom-center',
          style = {
            zoom = '1.5'
          }
        })
      elseif (coma_left < 1) then
        if not isTextOpen or (isTextOpen and text ~= RESPAWN_TEXT) then
          lib.hideTextUI()
          lib.showTextUI(RESPAWN_TEXT, {
            icon = 'face-smile',
            position = 'bottom-center',
            style = {
              zoom = '1.5'
            }
          })
        end

        if comaKey.disabled then
          comaKey:disable(false)
        end
      end
      Wait(1000)
    end
  end)
end

comaKey = lib.addKeybind({
  description = 'respawn when coma limit end',
  name = 'coma_revive',
  defaultKey = 'e',
  defaultMapper = 'keyboard',
  disabled = true,
  onPressed = function(self)
    if in_coma and coma_left < 1 then
      in_coma = false
      self:disable(true)
      lib.hideTextUI()
      RunDeathScene()
    end
  end
})

AddEventHandler('gameEventTriggered', function(name, data)
  if name == 'CEventNetworkEntityDamage' then
    local ped = cache.ped
    local vict = data[1]
    -- local attacker = data[2]
    local isFatal = data[6] == 1
    if vict == ped and isFatal and not in_coma then
      KillPlayer()
    end
  end
end)



-- RegisterCommand("kill", function (_, args, raw)
--   SetEntityHealth(cache.ped, 0.0)
-- end)

-- RegisterCommand("god", function (_, args, raw)
--   tvRP.revivePlayer()
-- end)

-- RegisterCommand("tpw", function (_, args, raw)
--   local blip = GetFirstBlipInfoId(8)
--   if blip then
--     local pos = GetBlipInfoIdCoord(blip)
--     StartPlayerTeleport(cache.playerId, pos.x, pos.y, pos.z, 0.0, true, true, false)
--   end
-- end)