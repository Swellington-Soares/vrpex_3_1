local DEFAULT_CONFIG <const> = {
	ped = true,
	headBlend = true,
	faceFeatures = true,
	headOverlays = true,
	components = true,
	props = true,
	allowExit = true,
	tattoos = true
}

local cam
local in_editor = false
local tattoo_cache = nil
local tattoo_player = {}
local isReversedCam = false
local lastCamPage = 'body'
local lastSide = nil
local isNuiOpen = false
local old_player_app
local callback
local isRotating = false

--Roupas retiradas
local old_components


local CAM_OFFSET = {
	head = {
		p = vec3(0.0, 0.5, 0.65),
		a = vec3(0.0, 0.0, 0.65),
		v = 48.0
	},
	body = {
		p = vec3(0.0, 1.5, 0.08),
		a = vec3(0.0, 0.0, 0.02),
		v = 65.0
	},
	foot = {
		p = vec3(0.0, 0.8, -0.8),
		a = vec3(0.0, 0.0, -0.8),
		v = 65.0
	},
}

local function round(value, places)
	if type(value) == 'string' then value = tonumber(value) end
	if type(value) ~= 'number' then error('Value must be a number') end

	if places then
		if type(places) == 'string' then places = tonumber(places) end
		if type(places) ~= 'number' then error('Places must be a number') end

		if places > 0 then
			local mult = 10 ^ (places or 0)
			return math.floor(value * mult + 0.5) / mult
		end
	end

	return math.floor(value + 0.5)
end

local FACE_FEATURES <const> = {
	[1] = 'noseWidth',
	[2] = 'nosePeakHigh',
	[3] = 'nosePeakSize',
	[4] = 'noseBoneHigh',
	[5] = 'nosePeakLowering',
	[6] = 'noseBoneTwist',
	[7] = 'eyeBrownHigh',
	[8] = 'eyeBrownForward',
	[9] = 'cheeksBoneHigh',
	[10] = 'cheeksBoneWidth',
	[11] = 'cheeksWidth',
	[12] = 'eyesOpening',
	[13] = 'lipsThickness',
	[14] = 'jawBoneWidth',
	[15] = 'jawBoneBackSize',
	[16] = 'chinBoneLowering',
	[17] = 'chinBoneLenght',
	[18] = 'chinBoneSize',
	[19] = 'chinHole',
	[20] = 'neckThickness',
};

local HEAD_OVERLAYS <const> = {
	[1] = 'blemishes',
	[2] = 'beard',
	[3] = 'eyebrows',
	[4] = 'ageing',
	[5] = 'makeUp',
	[6] = 'blush',
	[7] = 'complexion',
	[8] = 'sunDamage',
	[9] = 'lipstick',
	[10] = 'moleAndFreckles',
	[11] = 'chestHair',
	[12] = 'bodyBlemishes',
}



function _GetPedHeadBlendData(ped)
	local blob = string.rep('\0\0\0\0\0\0\0\0', 10)                      -- Generate sufficient struct memory.

	if not Citizen.InvokeNative(0x2746BD9D88C5C5D0, ped, blob, true) then -- Attempt to write into memory blob.
		return {
			shapeFirst = 0,
			shapeSecond = 0,
			shapeThird = 0,
			skinFirst = 0,
			skinSecond = 0,
			skinThird = 0,
			shapeMix = 0.0,
			skinMix = 0.0,
			thirdMix = 0.0,
			hasParent = false
		}
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

local function getPlayerStats(ped)
	local health = GetEntityHealth(ped)
	local maxHealth = GetEntityMaxHealth(ped)
	local armor = GetPedArmour(ped)
	return health, maxHealth, armor
end

local function setPedStats(ped, health, maxhealth, armor)
	SetEntityMaxHealth(ped, maxhealth)
	SetPedMaxHealth(ped, maxhealth)
	SetEntityHealth(ped, health)
	SetPedArmour(ped, armor)
end

local function isMpPed(ped)
	local model = GetEntityModel(ped)
	return model == `mp_m_freemode_01` or model == `mp_f_freemode_01`
end

local function getMpPedModelName(ped)
	return GetEntityModel(ped) == `mp_m_freemode_01` and 'mp_m_freemode_01' or 'mp_f_freemode_01'
end

local function isPlayerMpMale()
	return GetEntityModel(PlayerPedId()) == `mp_m_freemode_01`
end


local function isPedUnsignHighHels(ped)
	return GetPedConfigFlag(ped, 322, true)
end

local function getPedModel(ped)
	return GetEntityModel(ped)
end

local function getPedComponents(ped)
	local components = {}
	for i = 0, 11 do
		components['d' .. i] = {
			c = i,
			d = GetPedDrawableVariation(ped, i),
			t = GetPedTextureVariation(ped, i)
		}
	end
	return components
end

local function getPedProps(ped)
	local props = {}
	for _, v in next, { 0, 1, 2, 6, 7 } do
		local prop = GetPedPropIndex(ped, v)
		local texture = GetPedPropTextureIndex(ped, v)
		props['p' .. v] = {
			c = v,
			d = prop == 255 or prop == -1 and -1 or prop,
			t = prop == 255 or prop == -1 and -1 or texture,
		}
	end
	return props
end

local function getPedComponentsProps(ped)
	if not ped then return {} end
	return {
		components = getPedComponents(ped),
		props = getPedProps(ped)
	}
end

local function getPedHeadBlend(ped)
	return _GetPedHeadBlendData(ped) or {}
end

local function setPedHeadBlend(ped, data)
	if not data then return end
	if not isMpPed(ped) then return end
	SetPedHeadBlendData(ped,
		data.shapeFirst or 0,
		data.shapeSecond or 0,
		data.shapeThird or 0,
		data.skinFirst or 0,
		data.skinSecond or 0,
		data.skinThird or 0,
		(data.shapeMix or 0.0) + 0.0,
		(data.skinMix or 0.0) + 0.0,
		(data.thirdMix or 0.0) + 0.0,
		data.hasParent)
end

local function getPedFaceFeatures(ped)
	local faceFeature = {}
	for i, name in ipairs(FACE_FEATURES) do
		faceFeature[name] = round(GetPedFaceFeature(ped, i - 1) + 0.0, 2)
	end

	return faceFeature
end

local function getPedHeadOverlays(ped)
	local o = {}
	for index, name in ipairs(HEAD_OVERLAYS) do
		local success, ov, ctype, firstColor, secondColor, opacity = GetPedHeadOverlayData(ped, index - 1)
		if success then
			o[name] = {
				d = ov ~= 255 and ov or 0,
				ctype = ctype,
				color1 = firstColor,
				color2 = secondColor,
				opacity = ov ~= 255 and round(opacity + 0.0, 2) or 0.0
			}
		end
	end
	return o
end

local function getPedHair(ped)
	return {
		style = GetPedDrawableVariation(ped, 2),
		color1 = GetPedHairColor(ped),
		color2 = GetPedHairHighlightColor(ped),
		texture = GetPedTextureVariation(ped, 2),
		palette = GetPedPaletteVariation(ped, 2)
	}
end

local function getPedTattoos(ped)
	return GetPedDecorations(ped)
end

local function getPedAppearance(ped)
	local eyeColor = GetPedEyeColor(ped)
	return {
		model = getPedModel(ped),
		headBlend = getPedHeadBlend(ped),
		faceFeatures = getPedFaceFeatures(ped),
		headOverlays = getPedHeadOverlays(ped),
		components = getPedComponents(ped),
		props = getPedProps(ped),
		hair = getPedHair(ped),
		eyeColor = eyeColor < 32 and eyeColor or 0,
		tattoos = getPedTattoos(ped),
	}
end

local function setPlayerPedModel(model)

	local p = promise.new()
	local ped = PlayerPedId()
	if type(model) == "string" then model = joaat(model) end
	local currentModel = GetEntityModel(ped)
	if currentModel == model then
		p:resolve(true)
	else
		CreateThread(function()
			if not IsModelInCdimage(model) then
				p:resolve(false)
			else
				local timeout = GetGameTimer() + 10000
				RequestModel(model)
				while not HasModelLoaded(model) and GetGameTimer() < timeout do Wait(0) end
				if HasModelLoaded(model) then
					local ped = PlayerPedId()
					local h, m, a = getPlayerStats(ped)
					SetPlayerModel(PlayerId(), model)
					SetModelAsNoLongerNeeded(model)
					ped = PlayerPedId()
					if isMpPed(ped) then
						SetPedHeadBlendData(ped, 21, 0, 0, 0, 0, 0, 0.0, 0.0, 0.0, false)
						SetPedDefaultComponentVariation(ped)
					end
					setPedStats(ped, h, m, a)
					p:resolve(true)
				else
					p:resolve(false)
				end
			end
		end)
	end
	return Citizen.Await(p)
end

local function setPedComponent(ped, component)
	if (not component) then return end
	local id = component.c;
	local drawable = component.d
	local texture = component.t
	local excludeComponents <const> = {
		[0] = true,
		[2] = true
	}
	if excludeComponents[id] and isMpPed(ped) then return end
	SetPedComponentVariation(ped, id, drawable, texture, 0)
end

local function setPedComponents(ped, components)
	if not components then return end
	for _, item in next, components do
		setPedComponent(ped, item)
	end
end

local function setPedProp(ped, prop)
	if not prop then return end
	local id = prop.c
	local drawable = prop.d
	local texture = prop.t
	if drawable == -1 or drawable == 255 then
		ClearPedProp(ped, id)
	else
		SetPedPropIndex(ped, id, drawable, texture, true)
	end
end

local function setPedProps(ped, props)
	if not props then return end
	for _, item in next, props do
		setPedProp(ped, item)
	end
end


local function setPedComponentsAndProps(ped, custom)
	if not custom then return end
	setPedComponents(ped, custom?.components)
	setPedProps(ped, custom?.props)
end

local function setPedFaceFeatures(ped, faceFeatures)
	if not faceFeatures then return end
	for index, v in next, FACE_FEATURES do
		local scale = faceFeatures[v] or 0.0
		SetPedFaceFeature(ped, index - 1, round(scale + 0.0, 2))
	end
end

local function _setPedHeadOverlay(ped, index, overlay)
	if not overlay then return end
	local index = index or overlay.index
	local d = overlay.d
	local color1 = overlay.color1
	local color2 = overlay.color2
	local opacity = round(overlay.opacity + 0.001, 2)


	local ctype = 0
	if color1 > 0 or color2 > 0 then
		if index == 2 or index == 1 or index == 10 then
			ctype = 1
		elseif index == 4 or index == 5 or index == 8 then
			ctype = 2
		end
	end


	SetPedHeadOverlay(ped, index, d, opacity)
	SetPedHeadOverlayColor(ped, index, ctype, color1, color2)
end

local function setPedHeadOverlays(ped, overlays)
	if not overlays then return end
	for index, name in next, HEAD_OVERLAYS do
		local o = overlays[name]
		_setPedHeadOverlay(ped, index - 1, o)
	end
end

local function setPedHair(ped, hair)
	if not hair then return end
	SetPedComponentVariation(ped, 2, hair.style, hair.texture or 0, hair.palette or 0)
	SetPedHairTint(ped, hair.color1, hair.color2)
end

local function setPedEyeColor(ped, colorIndex)
	if not colorIndex then return end
	colorIndex = colorIndex > 31 and 31 or colorIndex
	colorIndex = colorIndex < 0 and 0 or colorIndex
	SetPedEyeColor(ped, colorIndex)
end

local function setPedTattoos(ped, tattooList)
	if not tattooList then return end
	ClearPedDecorations(ped)
	for _, item in next, tattooList do
		local collection = item[1]
		local overlay = item[2]
		AddPedDecorationFromHashes(ped, collection, overlay)
	end
end

local function setPedAppearance(ped, appearance)
	if not appearance then return end
	local components = appearance?.components
	local props = appearance?.props
	local headBlend = appearance?.headBlend
	local faceFeatures = appearance?.faceFeatures
	local headOverlays = appearance?.headOverlays
	local hair = appearance?.hair
	local eyeColor = appearance?.eyeColor
	local tattoos = appearance?.tattoos
	setPedComponents(ped, components)
	setPedProps(ped, props)
	setPedHeadBlend(ped, headBlend)
	setPedFaceFeatures(ped, faceFeatures)
	setPedHeadOverlays(ped, headOverlays)
	setPedHair(ped, hair)
	setPedEyeColor(ped, eyeColor)
	setPedTattoos(ped, tattoos)
end

local function setPlayerAppearance(appearance)
	if not appearance then return end
	local model = appearance?.model or `mp_m_freemode_01`	
	setPlayerPedModel(model)
	local ped = PlayerPedId()	
	setPedAppearance(ped, appearance)
end

local function getMaxOverlay()
	local m = {}
	for k, name in next, HEAD_OVERLAYS do
		m[name] = GetPedHeadOverlayNum(k - 1) - 1
	end
	return m
end

local function getMaxDrawable(ped)
	local m = {}
	for i = 1, 11 do
		m['d' .. i] = {
			d = GetNumberOfPedDrawableVariations(ped, i) - 1,
			t = GetNumberOfPedTextureVariations(ped, i, 0) - 1
		}
	end

	m['d2'] = nil
	return m
end

local function getMaxDrawableTexture(ped, component, drawableId)
	return GetNumberOfPedTextureVariations(ped, component, drawableId) - 1
end

local function getMaxProps(ped)
	local m = {}
	for _, v in next, { 0, 1, 2, 6, 7 } do
		m['p' .. v] = {
			d = GetNumberOfPedPropDrawableVariations(ped, v) - 1,
			t = GetNumberOfPedPropTextureVariations(ped, v, 0) - 1
		}
	end
	return m
end

local function getMaxPropTexture(ped, component, propId)
	return GetNumberOfPedPropTextureVariations(ped, component, propId) - 1
end

local function getTattooList(ped)
	if not isMpPed(ped) then return nil end
	if not tattoo_cache then
		local j = LoadResourceFile(GetCurrentResourceName(), 'data/tattoo.json')
		if j then
			local tattoos = json.decode(j)
			for i = 1, #tattoos do
				tattoos[i].label = GetLabelText(tattoos[i].label)
				tattoos[i].hashMale = ("%d_%d"):format(joaat(tattoos[i].collection) & 0xffffffff,
					joaat(tattoos[i].overlayMale) & 0xffffffff)
				tattoos[i].hashFemale = ("%d_%d"):format(joaat(tattoos[i].collection) & 0xffffffff,
					joaat(tattoos[i].overlayFemale) & 0xffffffff)
			end
			tattoo_cache = tattoos
		end
	end

	return tattoo_cache
end

local function getPedHairs(ped)
	local hair = getPedHair(ped)
	return {
		current = getPedHair(ped),
		max = GetNumberOfPedDrawableVariations(ped, 2) - 1,
		maxtexture = getMaxDrawableTexture(ped, 2, hair.style)
	}
end

local function disablePlayerControls()
	ClearPedTasksImmediately(PlayerPedId())
	in_editor = true
	CreateThread(function()
		while in_editor do
			DisableAllControlActions(0)
			HideHudAndRadarThisFrame()
			DisableFrontendThisFrame()
			Wait(0)
		end
	end)
end

local function changeCam(offsetId)
	print(offsetId)
	local o = CAM_OFFSET[offsetId]

	local ped = PlayerPedId()

	local cx, cy, cz = table.unpack(o.p)
	local ox, oy, oz = table.unpack(o.a)

	if lastSide == 'right' then
		if lastCamPage == 'head' then
			cx = -0.5
		else
			cx = -1.0
		end
		cy = 0.0
		ox = 0.0
		oy = 0.0
	elseif lastSide == 'left' then
		if lastCamPage == 'head' then
			cx = 0.5
		else
			cx = 1.0
		end
		cy = 0.0
		ox = 0.0
		oy = 0.0
	end

	if isReversedCam then
		cx = cx * -1.0
		cy = cy * -1.0
	end

	if offsetId == 'head' and isPedUnsignHighHels(ped) then
		cz = cz + 0.1
		oz = oz + 0.1
	end

	local pos = GetOffsetFromEntityInWorldCoords(ped, cx, cy, cz)
	local camx = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', pos.x, pos.y, pos.z, 0.0, 0.0, 0.0, o.v, false, 2)
	PointCamAtEntity(camx, ped, ox, oy, oz, true)

	if cam then
		while IsCamInterpolating(cam) do Wait(0) end
		SetCamActiveWithInterp(camx, cam, 1000, 1, 1)
		Wait(1001)
		SetCamActive(cam, false)
		SetCamActive(camx, true)
		DestroyCam(cam, true)
		cam = camx
	else
		cam = camx
		SetCamActive(camx, true)
		RenderScriptCams(true, true, 2000, false, false)
	end

	print('okokok')
end

local function exitPlayerCustomization(appearance)
	isNuiOpen = false
	in_editor = false
	SendNUIMessage({ action = 'CLOSE', data = {} })
	SetNuiFocus(false, false)
	RenderScriptCams(false, false, 250, true, true)
	Wait(250)
	DestroyCam(cam, true)
	local ped = PlayerPedId()
	ClearPedTasksImmediately(ped)
	SetEntityInvincible(ped, false)
	if not appearance then
		if old_player_app then
			setPlayerAppearance(old_player_app)
		end
	end

	ped = PlayerPedId()

	if callback then
		if appearance then
			if old_components then
				setPedComponents(ped, old_components.components)
				setPedProps(ped, old_components.props)
				old_components = nil
				Wait(1000)
			end
			callback(getPedAppearance(ped))
		else
			callback(nil)
		end
	end

	callback = nil
	old_player_app = nil
	cam = nil
	tattoo_player = {}
	isReversedCam = false
	lastCamPage = 'body'
	lastSide = false
end


local function savePlayerPreset()
	if not callback then return end
	callback({
		is_preset = true,
		preset = getPedComponentsProps(PlayerPedId())
	})
end


local function prepareOldTattoo(currentTattoo)
	local t = {}
	for _, v in next, currentTattoo do
		t[("%d_%d"):format(v[1], v[2])] = { c = v[1], o = v[2] }
	end
	return t
end

local function startPlayerCustomization(fn, config, disableControls, oldcam)
	if isNuiOpen then return end
	if not fn then error('callback function not found') end
	if not config then config = DEFAULT_CONFIG end
	

	callback = fn

	SendNUIMessage({
		action = 'OPEN',
		data = {
			config = config,
		}
	})

	isNuiOpen = true
	isReversedCam = false
	lastCamPage = 'body'

	local model = getPedModel(PlayerPedId())
	if model ~= `mp_m_freemode_01` and model ~= `mp_f_freemode_01` then
		setPlayerPedModel(`mp_m_freemode_01`)
	end

	if oldcam and DoesCamExist(oldcam) then
		cam = oldcam
	end

	Wait(0)
	changeCam(lastCamPage)

	if disableControls then
		disablePlayerControls()
	end

	old_player_app = getPedAppearance(PlayerPedId())
	tattoo_player = prepareOldTattoo(old_player_app.tattoos)

	SetNuiFocus(true, true)
end

local function rotatePed()
	if isRotating then return end
	isRotating = true
	CreateThread(function()
		local ped = PlayerPedId()
		local pos = GetEntityCoords(ped)
		ClearPedTasksImmediately(ped)
		FreezeEntityPosition(ped, false)
		TaskGoStraightToCoord(ped, pos.x, pos.y, pos.z, 8.0, 1500, GetEntityHeading(ped) + 180.0, 0.1)
		Wait(1500)
		isReversedCam = not isReversedCam
		isRotating = false
	end)
end

local function toggleComponents()
	local ped = PlayerPedId()
	if old_components then
		setPedComponents(ped, old_components.components)
		setPedProps(ped, old_components.props)
		old_components = nil
	else
		old_components = {}
		old_components.components = getPedComponents(ped)
		old_components.props = getPedProps(ped)
		local model = GetEntityModel(ped)
		setPedComponents(ped, SwAppearanceConfig[model].components)
		setPedProps(ped, SwAppearanceConfig[model].props)
	end
end

RegisterNUICallback('toggleShirt', function(_, cb)
	cb({ status = 'ok' })
	toggleComponents()
end)

RegisterNUICallback('getDrawables', function(data, cb)
	local ped = PlayerPedId()
	local m = getMaxDrawable(ped)
	local c = getPedComponents(ped)
	cb({
		max = m,
		current = c
	})
end)

RegisterNUICallback('getDrawableMaxTexture', function(data, cb)
	local ped = PlayerPedId()
	local max = getMaxDrawableTexture(ped, data.component, data.drawableId)
	setPedComponent(ped, { c = data.component, d = data.drawableId, t = 0 })
	cb({ max = max })
end)

RegisterNUICallback('setDrawableTexture', function(data, cb)
	setPedComponent(PlayerPedId(), { c = data.component, d = data.drawableId, t = data.texture })
	cb({ status = 'ok' })
end)

RegisterNUICallback('getProps', function(_, cb)
	local ped = PlayerPedId()
	local m = getMaxProps(ped)
	local c = getPedProps(ped)
	cb({
		max = m,
		current = c
	})
end)

RegisterNUICallback('getPropMaxTexture', function(data, cb)
	local ped = PlayerPedId()
	local max = 0
	if data.propId ~= -1 then
		max = getMaxPropTexture(ped, data.component, data.propId)
	end
	setPedProp(ped, { c = data.component, d = data.propId, t = 0 })
	cb({ max = max })
end)

RegisterNUICallback('setPropTexture', function(data, cb)
	cb({ status = 'ok' })
	setPedProp(PlayerPedId(), { c = data.component, d = data.propId, t = data.texture })
end)


RegisterNUICallback('getFaceFeature', function(_, cb)
	local face = getPedFaceFeatures(PlayerPedId())
	cb(face)
end)

RegisterNUICallback('setFaceFeature', function(data, cb)
	cb({ status = 'ok' })
	local id = data.k
	local scale = data.scale
	SetPedFaceFeature(PlayerPedId(), id, scale + 0.001)
end)


RegisterNUICallback('getHeadblend', function(_, cb)
	local headblend = getPedHeadBlend(PlayerPedId())
	cb(headblend)
end)

RegisterNUICallback('setHeadBlend', function(data, cb)
	setPedHeadBlend(PlayerPedId(), data)
	cb({ status = 'ok' })
end)


RegisterNUICallback('getTattooList', function(_, cb)
	local ped = PlayerPedId()
	cb({
		tattooList = getTattooList(ped),
		current = getPedTattoos(ped)
	})
end)


RegisterNUICallback('getOverlays', function(_, cb)
	local ped = PlayerPedId()
	local eyeColor = GetPedEyeColor(ped)
	cb({
		max = getMaxOverlay(),
		current = getPedHeadOverlays(ped),
		hair = getPedHairs(ped),
		eyeIndex = eyeColor < 32 and eyeColor or 0
	})
end)

RegisterNUICallback('setOverlay', function(data, cb)
	cb({ status = 'ok' })
	_setPedHeadOverlay(PlayerPedId(), data.id, data)
end)

RegisterNUICallback('setHair', function(data, cb)
	cb({ status = 'ok' })
	setPedHair(PlayerPedId(), data)
end)

RegisterNUICallback('setEye', function(data, cb)
	cb({ status = 'ok' })
	setPedEyeColor(PlayerPedId(), data.index)
end)

RegisterNUICallback('getGender', function(_, cb)
	local gender = isPlayerMpMale() and 'Masculino' or 'Feminino'
	cb({ gender = gender, defaultPed = getMpPedModelName(PlayerPedId()) })
end)

RegisterNUICallback('setGender', function(data, cb)
	local gender = isPlayerMpMale() and 'Masculino' or 'Feminino'
	if data.gender ~= gender then
		CreateThread(function()
			setPlayerPedModel(data.gender == 'Masculino' and `mp_m_freemode_01` or `mp_f_freemode_01`)
			tattoo_player = {}
			ClearPedDecorations(PlayerPedId())
			Wait(1000)
			SendNUIMessage({ action = 'updatePed', data = { gender = data.gender, defaultPed = getMpPedModelName(PlayerPedId()) } })
			old_components = nil
		end)
	end
	cb({ status = 'ok' })
end)


RegisterNUICallback("setTattoo", function(data, cb)
	cb({ status = 'ok' })
	local ped = PlayerPedId()
	ClearPedDecorations(ped)
	-- local hash = isPlayerMpMale() and data.hashMale or data.hashFemale
	if data.action == 'remove' then
		tattoo_player[data.hash] = nil
	else
		tattoo_player[data.hash] = { c = data.c, o = data.o }
	end

	for _, tattoo in next, tattoo_player do
		AddPedDecorationFromHashes(ped, tattoo.c, tattoo.o)
	end
end)

RegisterNUICallback('change-cam', function(data, cb)
	cb({ status = 'ok' })
	if (data.cam == 'head' or data.cam == 'body' or data.cam == 'foot') and lastCamPage ~= data.cam then
		lastCamPage = data.cam
		changeCam(data.cam)
	elseif (data.cam == 'left' or data.cam == 'right') then
		lastSide = lastSide ~= data.cam and data.cam or nil
		changeCam(lastCamPage)
	elseif data.cam == 'rotatePed' then
		-- isReversedCam = not isReversedCam
		-- changeCam(lastCamPage)
		rotatePed()
	end
end)

RegisterNUICallback('quit', function(data, cb)
	cb({ status = 'ok' })
	exitPlayerCustomization(data.save)
end)

RegisterNUICallback('save-preset', function(_, cb)
	cb({ status = 'ok' })
	savePlayerPreset()
end)

exports('getPedPedModel', getPedModel)
exports('getPedComponents', getPedComponents)
exports('getPedProps', getPedProps)
exports('getPedHeadBlend', getPedHeadBlend)
exports('getPedFaceFeatures', getPedFaceFeatures)
exports('getPedHeadOverlays', getPedHeadOverlays)
exports('getPedHair', getPedHair)
exports('getPedTattoos', getPedTattoos)
exports('getPedAppearance', getPedAppearance)
exports('getPedComponentsProps', getPedComponentsProps)

exports('setPlayerPedModel', setPlayerPedModel)
exports('setPedComponent', setPedComponent)
exports('setPedComponents', setPedComponents)
exports('setPedProp', setPedProp)
exports('setPedProps', setPedProps)
exports('setPedFaceFeatures', setPedFaceFeatures)
exports('setPedHeadOverlays', setPedHeadOverlays)
exports('setPedHair', setPedHair)
exports('setPedEyeColor', setPedEyeColor)
exports('setPedTattoos', setPedTattoos)
exports('setPedAppearance', setPedAppearance)
exports('setPlayerAppearance', setPlayerAppearance)
exports('startPlayerCustomization', startPlayerCustomization)
exports('setPedComponentsAndProps', setPedComponentsAndProps)
