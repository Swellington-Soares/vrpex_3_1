-- api
local scaleform <const> = "MP_BIG_MESSAGE_FREEMODE"
local COMA_TEXT <const> = 'Espere por ajuda...'
local RESPAWN_TEXT <const> = 'Pressione [E] para tentar novamente, ou espere.'

---@type CKeybind
local comaKey

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
          timeout = GetGameTimer() + 12000
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
local coma_left = cfg.coma_duration * 60


function tvRP.revivePlayer()
  in_coma = false
  coma_left = cfg.coma_duration * 60
  comaKey:disable(true)
  local pos = GetEntityCoords(cache.ped)
  FreezeEntityPosition(cache.ped, false)
  SetPlayerControl(cache.playerId, true, 0)
  Wait(0)
  NetworkResurrectLocalPlayer(pos.x, pos.y, pos.z, GetEntityHeading(cache.ped), 2000, false)
  lib.hideTextUI()
  tvRP.setHealth(200)
  ClearPedBloodDamage(cache.ped)
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

Citizen.CreateThread(function() -- disable health regen, conflicts with coma system
  while true do
    Citizen.Wait(100)
    SetPlayerHealthRechargeMultiplier(PlayerId(), 0.0)
  end
end)


local function KillPlayer()
  coma_left = cfg.coma_duration * 60
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
      if (not isTextOpen or (isTextOpen and text ~= COMA_TEXT)) and coma_left > 0 then
        lib.showTextUI(COMA_TEXT, {
          icon = 'skull',
          position = 'bottom-center',
          style = {
            zoom = '1.5'
          }
        })
      elseif (coma_left < 1) then
        if not (isTextOpen or (isTextOpen and text ~= RESPAWN_TEXT)) then
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
      Wait(500)
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
      tvRP.revivePlayer()
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
