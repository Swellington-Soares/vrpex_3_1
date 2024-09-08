-- periodic player state update
local function SetPedSingleOverlayData(id, ped, data)
  ped = ped or PlayerPedId()
  if not data then return end
  local overlayValue, colourType, firstColour, secondColour, overlayOpacity = table.unpack(data)
  overlayValue = overlayValue == -1 and 255 or overlayValue
  local colourType = 0
  if firstColour > 0 or secondColour > 0 then
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

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(60000)

    if IsPlayerPlaying(PlayerId()) and LocalPlayer.state.isLoggedIn then
      -- local x,y,z = table.unpack(GetEntityCoords(PlayerPedId(),true))
      -- vRPserver._updatePos(x,y,z)
      -- vRPserver._updateHealth(tvRP.getHealth())
      -- vRPserver._updateWeapons(tvRP.getWeapons())
      vRPserver._updateCustomization(tvRP.getCustomization())
    end
  end
end)


-- PLAYER CUSTOMIZATION

-- parse part key (a ped part or a prop part)
-- return is_proppart, index
local function parse_part(key)
  if type(key) == "string" and string.sub(key, 1, 1) == "p" then
    return true, tonumber(string.sub(key, 2))
  else
    return false, tonumber(key)
  end
end

function tvRP.getDrawables(part)
  local isprop, index = parse_part(part)
  if isprop then
    return GetNumberOfPedPropDrawableVariations(PlayerPedId(), index)
  else
    return GetNumberOfPedDrawableVariations(PlayerPedId(), index)
  end
end

function tvRP.getDrawableTextures(part, drawable)
  local isprop, index = parse_part(part)
  if isprop then
    return GetNumberOfPedPropTextureVariations(PlayerPedId(), index, drawable)
  else
    return GetNumberOfPedTextureVariations(PlayerPedId(), index, drawable)
  end
end

function tvRP.getCustomization()
  -- local ped = PlayerPedId()
  
  -- local custom = {
  --   modelhash = GetEntityModel(ped),
  --   components = {}, --roupas
  --   props = {},      -- props
  --   overlay = {},    -- maquiagem e afins
  --   face = {},       -- rosto
  --   eye = 0,
  --   hair = {
  --     color1 = 0,
  --     color2 = 0,
  --   } -- caso especial
  -- }

  -- for i = 1, 11 do
  --   custom.components[i] = { GetPedDrawableVariation(ped, i), GetPedTextureVariation(ped, i), GetPedPaletteVariation(ped,
  --     i) }
  -- end

  -- for _, i in next, { 0, 1, 2, 6, 7 } do
  --   custom.props[i] = { GetPedPropIndex(ped, i), math.max(GetPedPropTextureIndex(ped, i), 0) }
  -- end

  -- custom.hair.color1 = GetPedHairColor(ped)
  -- custom.hair.color2 = GetPedHairHighlightColor(ped)

  -- custom.eye = GetPedEyeColor(ped)

  -- for i = 0, 11 do
  --   local _, overlayValue, colourType, firstColour, secondColour, overlayOpacity = GetPedHeadOverlayData(ped, i)
  --   custom.overlay[i] = { overlayValue or 0, colourType or 0, firstColour or 0, secondColour or 0, overlayOpacity or 0.0 }
  -- end

  -- custom.face = GetPedHeadBlendData(ped)

  return exports.sw_appearance:getPedAppearance(PlayerPedId())
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
        SetPedComponentVariation(ped, i, custom.components[i][1], custom.components[i][2] or 0,
          custom?.components[i][3] or 0)
      end
    end

    ClearAllPedProps(ped)

    for k, v in next, custom?.props or {} do
      if v[1] ~= -1 and v[1] ~= 255 then
        SetPedPropIndex(ped, k, v[1], v[2], true)
      end
    end

    for k, v in next, custom?.overlay or {} do
      SetPedSingleOverlayData(k, ped, v)
    end

    Wait(500)

    r:resolve()
  end)
  Citizen.Await(r)
  return true
end

RegisterNetEvent('vrp:client:weapon_sync', function(_t, _w, _data)
  if GetInvokingResource() then return end
  if _t == "LIVERY" then
    for _, lv in next, _data or {} do
      if IsPedWeaponComponentActive(cache.ped, _w, lv) then
        SetPedWeaponLiveryColor(cache.ped, _w, lv.comp, lv.color or 0)
      end
    end
  elseif _t == 'TINT' then
    SetPedWeaponTintIndex(cache.ped, _w, _data)
  end
end)
