
-- periodic player state update
local function SetPedSingleOverlayData(id, ped, data)
  ped = ped or PlayerPedId()
  if not data then return end
  local overlayValue, colourType, firstColour, secondColour, overlayOpacity = table.unpack(data)
  overlayValue = overlayValue == -1 and 255 or overlayValue
  local colourType = 0
  if firstColour>0 or secondColour>0 then
      if id == 2 or id == 1 or id == 10 then
          colourType = 1
      elseif id == 4 or id == 5 or id == 8 then
          colourType = 2
      end
  end
  SetPedHeadOverlay(ped, id, overlayValue, lib.math.round(overlayOpacity, 2))
  SetPedHeadOverlayColor(ped, id, colourType, firstColour, secondColour)
end


function GetPedHeadBlendData(ped)
  local blob = string.rep('\0\0\0\0\0\0\0\0', 10)                       -- Generate sufficient struct memory.
  if not Citizen.InvokeNative(0x2746BD9D88C5C5D0, ped, blob, true) then -- Attempt to write into memory blob.
      return false
  end

  return {
      shapeFirst = string.unpack('<i4', blob, 1),
      shapeSecond = string.unpack('<i4', blob, 9),
      shapeThird = string.unpack('<i4', blob, 17),
      skinFirst = string.unpack('<i4', blob, 25),
      skinSecond = string.unpack('<i4', blob, 33),
      skinThird = string.unpack('<i4', blob, 41),
      shapeMix = string.unpack('<f', blob, 49),
      skinMix = string.unpack('<f', blob, 57),
      thirdMix = string.unpack('<f', blob, 65),
      hasParent = string.unpack('b', blob, 73) ~= 0
  }
end

local state_ready = false

function tvRP.playerStateReady(state)
  state_ready = state
end

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(30000)

    if IsPlayerPlaying(PlayerId()) and state_ready then
      local x,y,z = table.unpack(GetEntityCoords(PlayerPedId(),true))
      vRPserver._updatePos(x,y,z)
      vRPserver._updateHealth(tvRP.getHealth())
      vRPserver._updateWeapons(tvRP.getWeapons())
      vRPserver._updateCustomization(tvRP.getCustomization())
    end
  end
end)

-- WEAPONS

-- def
local weapon_types = {
  "WEAPON_KNIFE",
  "WEAPON_STUNGUN",
  "WEAPON_FLASHLIGHT",
  "WEAPON_NIGHTSTICK",
  "WEAPON_HAMMER",
  "WEAPON_BAT",
  "WEAPON_GOLFCLUB",
  "WEAPON_CROWBAR",
  "WEAPON_PISTOL",
  "WEAPON_COMBATPISTOL",
  "WEAPON_APPISTOL",
  "WEAPON_PISTOL50",
  "WEAPON_MICROSMG",
  "WEAPON_SMG",
  "WEAPON_ASSAULTSMG",
  "WEAPON_ASSAULTRIFLE",
  "WEAPON_CARBINERIFLE",
  "WEAPON_ADVANCEDRIFLE",
  "WEAPON_MG",
  "WEAPON_COMBATMG",
  "WEAPON_PUMPSHOTGUN",
  "WEAPON_SAWNOFFSHOTGUN",
  "WEAPON_ASSAULTSHOTGUN",
  "WEAPON_BULLPUPSHOTGUN",
  "WEAPON_STUNGUN",
  "WEAPON_SNIPERRIFLE",
  "WEAPON_HEAVYSNIPER",
  "WEAPON_REMOTESNIPER",
  "WEAPON_GRENADELAUNCHER",
  "WEAPON_GRENADELAUNCHER_SMOKE",
  "WEAPON_RPG",
  "WEAPON_PASSENGER_ROCKET",
  "WEAPON_AIRSTRIKE_ROCKET",
  "WEAPON_STINGER",
  "WEAPON_MINIGUN",
  "WEAPON_GRENADE",
  "WEAPON_STICKYBOMB",
  "WEAPON_SMOKEGRENADE",
  "WEAPON_BZGAS",
  "WEAPON_MOLOTOV",
  "WEAPON_FIREEXTINGUISHER",
  "WEAPON_PETROLCAN",
  "WEAPON_DIGISCANNER",
  "WEAPON_BRIEFCASE",
  "WEAPON_BRIEFCASE_02",
  "WEAPON_BALL",
  "WEAPON_FLARE"
}

function tvRP.getWeaponTypes()
  return weapon_types
end


--TODO: MODIFY TO DETECT METADATA AND ATTACH OR OTHER THINGS
function tvRP.getWeapons()
  local player = PlayerPedId()

  local ammo_types = {} -- remember ammo type to not duplicate ammo amount

  local weapons = {}
  for k,v in pairs(weapon_types) do
    local hash = joaat(v)
    if HasPedGotWeapon(player, hash, false) then
      local weapon = {}
      weapons[v] = weapon
      local atype = GetPedAmmoTypeFromWeapon( player, hash)
      if ammo_types[atype] == nil then
        ammo_types[atype] = true
        weapon.ammo = GetAmmoInPedWeapon(player,hash)
      else
        weapon.ammo = 0
      end
    end
  end

  return weapons
end

-- replace weapons (combination of getWeapons and giveWeapons)
-- return previous weapons
function tvRP.replaceWeapons(weapons)
  local old_weapons = tvRP.getWeapons()
  tvRP.giveWeapons(weapons, true)
  return old_weapons
end

function tvRP.giveWeapons(weapons,clear_before)
  local player = PlayerPedId()

  -- give weapons to player

  if clear_before then
    RemoveAllPedWeapons(player,true)
  end

  for k,weapon in pairs(weapons) do
    local hash = GetHashKey(k)
    local ammo = weapon.ammo or 0

    GiveWeaponToPed(player, hash, ammo, false, false)
  end
end

-- set player armour (0-100)
function tvRP.setArmour(amount)
  SetPedArmour(PlayerPedId(), amount)
end

-- PLAYER CUSTOMIZATION

-- parse part key (a ped part or a prop part)
-- return is_proppart, index
local function parse_part(key)
  if type(key) == "string" and string.sub(key,1,1) == "p" then
    return true,tonumber(string.sub(key,2))
  else
    return false,tonumber(key)
  end
end

function tvRP.getDrawables(part)
  local isprop, index = parse_part(part)
  if isprop then
    return GetNumberOfPedPropDrawableVariations(PlayerPedId(),index)
  else
    return GetNumberOfPedDrawableVariations(PlayerPedId(),index)
  end
end

function tvRP.getDrawableTextures(part,drawable)
  local isprop, index = parse_part(part)
  if isprop then
    return GetNumberOfPedPropTextureVariations(PlayerPedId(),index,drawable)
  else
    return GetNumberOfPedTextureVariations(PlayerPedId(),index,drawable)
  end
end

function tvRP.getCustomization()
  local ped = PlayerPedId()

  local custom = {
    modelhash = GetEntityModel(ped),
    components = {}, --roupas
    props = {}, -- props
    overlay = {}, -- maquiagem e afins
    face = {}, -- rosto
    eye = 0,
    hair = {
      color1 = 0,
      color2 = 0,
    } -- caso especial
  }

  for i = 1, 11 do
    custom.components[i] = {GetPedDrawableVariation(ped,i), GetPedTextureVariation(ped,i), GetPedPaletteVariation(ped,i)}
  end  

  for _, i in next, { 0, 1, 2, 6, 7 } do
    custom.props[i] = {GetPedPropIndex(ped,i), math.max(GetPedPropTextureIndex(ped,i),0)}
  end

  custom.hair.color1 = GetPedHairColor(ped)
  custom.hair.color2 = GetPedHairHighlightColor(ped)

  custom.eye = GetPedEyeColor(ped)

  for i = 0, 11 do
    local _, overlayValue, colourType, firstColour, secondColour, overlayOpacity = GetPedHeadOverlayData(ped, i)
    custom.overlay[i] = { overlayValue or 0, colourType or 0, firstColour or 0, secondColour or 0, overlayOpacity or 0.0 }
  end
  
  custom.face = GetPedHeadBlendData(ped)

  return custom
end


function tvRP.setCustomization(custom)
  local r = promise.new()
  CreateThread(function()
      local ped = PlayerPedId()
      local pedModel = GetEntityModel(ped)        
      local customModel = custom?.modelhash and joaat(custom.modelhash) or pedModel
      local weapons = tvRP.getWeapons()
      local armour = GetPedArmour(ped)
      local health = GetEntityHealth(ped)
      local IsDifferentModel = false
      if customModel ~= pedModel then
        local model = lib.requestModel(customModel, 5000)
        SetPlayerModel(PlayerId(), model)
        Wait(1000)
        ped = PlayerPedId()        
        SetModelAsNoLongerNeeded(model)
        IsDifferentModel = true
      end      
      
      tvRP.giveWeapons(weapons, true)      
      tvRP.setArmour(armour)
      tvRP.setHealth(health)

      if IsDifferentModel then
        SetPedHeadBlendData(ped,
            custom?.face?.shapeFirst or 0,
            custom?.face?.shapeSecond or 0,
            custom?.face?.shapeThird or 0,
            custom?.face?.skinFirst or 0,
            custom?.face?.skinSecond or 0,
            custom?.face?.skinThird or 0,
            custom?.face?.shapeMix or 0,
            custom?.face?.skinMix or 0.0,
            custom?.face?.thirdMix or 0.0,
            custom?.face?.hasParent or false
          )       
          
          SetPedEyeColor(ped, custom?.eye or 0)
      end

      for i = 1, 11 do
        if custom?.components[i] then
          SetPedComponentVariation(ped, i, custom.components[i][1], custom.components[i][2] or 0, custom?.components[i][3] or 0)
        end
      end

      ClearAllPedProps(ped)

      for k, v in next, custom?.props or {} do
          if v[1] ~= -1 and v [1]~= 255 then
            SetPedPropIndex(ped, k, v[1], v[2], true )
          end
      end

      for k ,v in next, custom?.overlay or {} do
        SetPedSingleOverlayData(k, ped, v)
      end

      Wait(500)

      r:resolve()
  end)
  Citizen.Await(r)
  return true
end