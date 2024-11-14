local config = require('@multichar.config')

local chars = {}
local previewPeds = {}
local selectedPed
local currentSelectedSlot = 1
local inCharCreator = true
local cam

local isloading = false
local loadingMessage = 'Carregando...'
local isCamTransiting = false

local subcaption = ''

CreateThread(function()
    LocalPlayer.state.canEmote = false
    TriggerServerEvent('vrp:player:ready', false)
    LocalPlayer.state:set('isLoggedIn', false, true)
    while inCharCreator do
        SetFrontendActive(false)
        HideHudAndRadarThisFrame()
        DisableAllControlActions(0)
        DisableAllControlActions(1)
        Wait(0)
    end
end)

local function DeletePreviewPeds()
    inCharCreator = false
    Wait(100)
    for _, p in next, previewPeds do
        SetEntityAsMissionEntity(p, true, true)
        DeleteEntity(p)
    end
end

local function teleport(_x, _y, _z)
    if IsPlayerSwitchInProgress() then return end

    SwitchToMultiFirstpart(cache.ped, 0, 1)
    CreateThread(function()
        while IsPlayerSwitchInProgress() do
            Wait(0)
            SetCloudHatOpacity(0)
        end
    end)
    while GetPlayerSwitchState() ~= 5 do Wait(0) end

    local vehicle = GetVehiclePedIsIn(cache.ped, false)
    local oldCoords <const> = GetEntityCoords(cache.ped)

    -- Unpack coords instead of having to unpack them while iterating.
    -- 825.0 seems to be the max a player can reach while 0.0 being the lowest.
    local x, y, groundZ, Z_START = _x, _y, 850.0, 950.0
    local found = false
    if vehicle > 0 then
        FreezeEntityPosition(vehicle, true)
    else
        FreezeEntityPosition(cache.ped, true)
    end

    for i = Z_START, 0, -25.0 do
        local z = i
        if (i % 2) ~= 0 then
            z = Z_START - i
        end

        NewLoadSceneStart(x, y, z, 0.0, 0.0, 0.0, 50.0, 0)
        local curTime = GetGameTimer()
        while IsNetworkLoadingScene() do
            if GetGameTimer() - curTime > 1000 then
                break
            end
            Wait(0)
        end
        NewLoadSceneStop()
        SetPedCoordsKeepVehicle(cache.ped, x, y, z)

        while not HasCollisionLoadedAroundEntity(cache.ped) do
            RequestCollisionAtCoord(x, y, z)
            if GetGameTimer() - curTime > 1000 then
                break
            end
            Wait(0)
        end

        -- Get ground coord. As mentioned in the natives, this only works if the client is in render distance.
        found, groundZ = GetGroundZFor_3dCoord(x, y, z, false);
        if found then
            Wait(0)
            SetPedCoordsKeepVehicle(cache.ped, x, y, groundZ)
            break
        end
    end

    if vehicle > 0 then
        FreezeEntityPosition(vehicle, false)
    else
        FreezeEntityPosition(cache.ped, false)
    end

    if not found then
        -- If we can't find the coords, set the coords to the old ones.
        -- We don't unpack them before since they aren't in a loop and only called once.
        SetPedCoordsKeepVehicle(cache.ped, oldCoords.x, oldCoords.y, oldCoords.z - 1.0)
        SwitchToMultiSecondpart(cache.ped)
        return
    end

    -- If Z coord was found, set coords in found coords.
    SetPedCoordsKeepVehicle(cache.ped, x, y, groundZ)
    SwitchToMultiSecondpart(cache.ped)
end

function Draw2DText(x, y, text, scale, r, g, b, font)
    SetTextFont(font or 7)
    SetTextProportional(true)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, 255)
    SetTextDropShadow()
    SetTextCentre(true)
    SetTextEdge(4, 0, 0, 0, 255)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

local function CreatePedSlot(slot, ch)
    local info = config.slots[slot]
    if not info then return end
    local pos = info.pos
    local anim = info.scenario
    local ped
    if not ch then
        local model = lib.requestModel(`mp_m_freemode_01`, 15000)
        ped = CreatePed(4, model, pos.x, pos.y, pos.z, pos.w, false, true)
        SetModelAsNoLongerNeeded(model)
        SetPedHeadBlendData(ped, 0, 0, 0, 0, 0, 0, 0.0, 0.0, 0.0, false)
        Wait(0)
        SetPedDefaultComponentVariation(ped)
    else
        local model = lib.requestModel(ch?.skin?.model or `mp_m_freemode_01`, 15000)
        ped = CreatePed(4, model, pos.x, pos.y, pos.z, pos.w, false, true)
        SetModelAsNoLongerNeeded(model)
        Wait(0)
        exports.sw_appearance:setPedAppearance(ped, ch?.skin)
    end
    SetEntityAsMissionEntity(ped, true, true)
    FreezeEntityPosition(ped, true)
    SetEntityCoordsNoOffset(ped, pos.x, pos.y, pos.z, pos.w, false, false)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetEntityInvincible(ped, true)
    if anim then
        TaskStartScenarioInPlace(ped, anim, 0, true)
    end

    previewPeds[slot] = ped
end

local function StartPreviewCam()
    local pos = config.player_location
    cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', pos.x, pos.y, pos.z + 3.0, -90.0, 0.0, 0.0, 55.0, true, 2)
    RenderScriptCams(true, true, 1000, true, true)
end

local function StartLoadingThread()
    if isloading then return end
    isloading = true
    CreateThread(function()
        while isloading do
            Draw2DText(0.5, 0.47, loadingMessage, 1.8, 66, 141, 245)
            DrawRect(0.5, 0.52, 1.0, 0.2, 0, 0, 0, 150)
            Wait(0)
        end
        isloading = false
    end)
end

local function PreSpawn()
    DeletePreviewPeds()
    LocalPlayer.state.canEmote = true
    local ped = PlayerPedId()
    FreezeEntityPosition(ped, false)
    ClearPedTasksImmediately(ped)
    SetEntityInvincible(ped, false)
    inCharCreator = false
end

local function PosSpawn()
    NetworkEndTutorialSession()
    while NetworkIsTutorialSessionChangePending() do Wait(0) end
    LocalPlayer.state:set('isLoggedIn', true, true)
    TriggerServerEvent('vrp:player:ready', true)
    TriggerEvent('playerReady')
    SetEntityVisible(cache.ped, true, false)
    SetEntityInvincible(cache.ped, false)
end

local function SpawnPlayer(x, y, z, isHome)
    if DoesCamExist(cam) then
        RenderScriptCams(false, false, 0, false, true)
        DestroyCam(cam, true)
        cam = nil
    end
    if not isHome then
        teleport(x, y, z)
    else
        local ped = PlayerPedId()
        DoScreenFadeOut(0)
        RenderScriptCams(false, true, 1000, true, true)
        ClearFocus()
        FreezeEntityPosition(ped, false)
        ClearPedTasksImmediately(ped)
        TriggerServerEvent('ps-housing:server:enterProperty', tostring(isHome.property_id))
        Wait(1000)
        ClearPedTasksImmediately(PlayerPedId())
        FreezeEntityPosition(PlayerPedId(), false)
    end
    PosSpawn()
end

local function CreateSpawnMenu()
    if not DoesCamExist(cam) then
        local pos = config.player_location
        cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', pos.x, pos.y, pos.z + 150.0, -90.0, 0.0, 0.0, 55.0, true, 2)
        RenderScriptCams(true, true, 1000, true, true)
    end

    local char = chars[currentSelectedSlot]
    local lastPos = char?.last_location
    local options = {}
    if lastPos or char?.inside then
        options[#options + 1] = { label = locale('last_location'), args = { vec4(lastPos.x, lastPos.y, lastPos.z, 0.0), home = char?.inside } }
    end
    for _, info in next, config.spawn_coords or {} do
        options[#options + 1] = { label = info.title, args = { info.pos } }
    end

    lib.registerMenu({
        id = 'spawn_menu',
        title = locale('select_spawn'),
        canClose = false,
        disableInput = true,
        position = 'top-left',
        options = options,
        onSelected = function(selected, _, args, _)
            if not args?.home then
                local pos = args[1]
                SetCamCoord(cam, pos.x, pos.y, pos.z + 150.0)
                SetCamRot(cam, -90.0, 0.0, 0.0, 2)
                SetFocusPosAndVel(pos.x, pos.y, pos.z, 0.0, 0.0, 0.0)
            end
        end
    }, function(_, _, args)
        local pos = args[1]
        SpawnPlayer(pos.x, pos.y, pos.z, args.home)
    end)

    lib.showMenu('spawn_menu')
    ClearFocus()
end

local function StartTextThread()
    CreateThread(function()
        while inCharCreator do
            Draw2DText(0.5, 0.90, subcaption, 1.0, 255, 255, 255, 1)
            Wait(0)
        end
    end)
end

local function Validate(f, l)
    if not f or not f:match("^[%aÀ-ÖØ-öø-ÿ]+$") then
        return false, locale('firstname_invalid')
    end

    if not l or not l:match("^[%aÀ-ÖØ-öø-ÿ]+$") then
        return false, locale('lastname_invalid')
    end

    return true
end

local function CreateNewPlayerScreenRegister()
    local ped = PlayerPedId()
    local pos = config.player_location
    FreezeEntityPosition(ped, true)
    SetEntityCoordsNoOffset(ped, pos.x, pos.y, pos.z, false, false, false)
    SetEntityHeading(ped, pos.w)
    SetEntityVisible(ped, true, true)
    SetPedHeadBlendData(ped, 0, 0, 0, 0, 0, 0, 0.0, 0.0, 0.0, false)
    SetPedDefaultComponentVariation(ped)
    ClearFocus()
    ClearPedTasksImmediately(ped)
    local charId
    local finishedRegister = promise.new()
    isloading = false
    CreateThread(function()
        while true do
            Wait(0)
            local input = lib.inputDialog(locale('register_menu_title'),
                {
                    { type = 'input', label = locale('firstname'), required = true, min = 4, max = 20, default = '', placeholder = 'João' },
                    { type = 'input', label = locale('lastname'),  required = true, min = 4, max = 20, default = '', placeholder = 'Santos' },
                    {
                        type = 'select',
                        label = locale('gender'),
                        required = true,
                        icon = 'transgender',
                        options = {
                            { value = 'M', label = 'Masculino' },
                            { value = 'F', label = 'Feminino' },
                        },
                        default = 'M'
                    },
                    { type = 'date', label = locale('birthdate'), icon = { 'far', 'calendar' }, required = true, format = "DD/MM/YYYY", default = '2000/02/02' }
                }, { allowCancel = false })
            if input then
                local firstname = input[1]
                local lastname = input[2]
                local gender = input[3]
                local date = input[4]

                local isValid, xmessage = Validate(firstname, lastname)

                if not isValid then
                    lib.notify({
                        position = 'top',
                        duration = 5000,
                        title = xmessage,
                        type = 'error',
                        style = {
                            zoom = '1.5',
                        }
                    })
                end

                local created, message, char_id = lib.callback.await('multichar:server:createchar', false, firstname,
                    lastname, date, gender)

                lib.notify({
                    position = 'top',
                    duration = 5000,
                    title = message,
                    type = created and 'success' or 'error',
                    style = {
                        zoom = '1.5',
                    }
                })

                if created then
                    charId = char_id
                    finishedRegister:resolve(true)
                    local model = lib.requestModel(gender == 'M' and `mp_m_freemode_01` or `mp_f_freemode_01`)
                    Wait(0)
                    SetPlayerModel(PlayerId(), model)
                    Wait(0)
                    ped = PlayerPedId()
                    SetEntityCoordsNoOffset(ped, pos.x, pos.y, pos.z, false, false, false)
                    SetEntityHeading(ped, pos.w)
                    SetModelAsNoLongerNeeded(model)
                    SetPedDefaultComponentVariation(ped)
                    print('ok-CREATED')
                end
                break
            end
        end
    end)
    Citizen.Await(finishedRegister)
    Wait(0)
    local config = {
        ped = false,
        headBlend = true,
        faceFeatures = true,
        headOverlays = true,
        components = true,
        props = true,
        allowExit = false,
        tattoos = true
    }
    exports.sw_appearance:startPlayerCustomization(function(appearance)
        DoScreenFadeOut(100)
        Wait(100)
        TriggerServerEvent('vrp:server:updatePlayerAppearance', charId, appearance)
        Wait(0)
        ClearFocus()
        PreSpawn()
        Wait(0)
        if config.use_intro then
            currentSelectedSlot = -1
            RunIntro()
        else
            CreateSpawnMenu()
            Wait(1000)
            DoScreenFadeIn(100)
        end
    end, config, true, cam)
end

local function CalculateDirectionOffset(heading, distance)
    local x = math.sin(math.rad(heading)) * distance
    local y = math.cos(math.rad(heading)) * distance
    return vec3(x, y, 0.0)
end

local function UpddateSelectionCam()
    isCamTransiting = true
    local h = GetEntityHeading(selectedPed)
    local of = CalculateDirectionOffset(h, 2.0)
    local camx = CreateCam('DEFAULT_SCRIPTED_CAMERA', false)
    local pos = GetEntityCoords(selectedPed)
    SetCamCoord(camx, pos.x - of.x, pos.y + of.y, pos.z)
    SetCamRot(camx, 0.0, 0.0, h + 180.0, 2)
    SetCamActiveWithInterp(camx, cam, 1000, 0, 1)
    while IsCamInterpolating(camx) do
        Wait(0)
    end
    SetCamActive(cam, false)
    DestroyCam(cam, true)
    cam = camx
    isCamTransiting = false
end

local function UpdateSubcaptionText()
    if chars[currentSelectedSlot] then
        if not chars[currentSelectedSlot]?.deleted then
            subcaption = ('Entrar com ~g~~h~%s %s~h~~s~?'):format(chars[currentSelectedSlot].firstname,
            chars[currentSelectedSlot].lastname)
        else
            subcaption = ''
        end
    else
        subcaption = 'Criar um novo ~o~~h~personagem~h~~s~?'
    end
end

local function SetCharAsDeleted(slot)
    chars[currentSelectedSlot].deleted = true
    local ped = previewPeds[slot]
    ClearPedTasksImmediately(ped)
    local anim = { 'anim@amb@business@bgen@bgen_no_work@', 'sit_phone_phoneputdown_idle_nowork' }
    lib.requestAnimDict(anim[1])
    TaskPlayAnim(ped, anim[1], anim[2], 4.0, -4.0, -1, 2, 0.0, false, false, false)    
    RemoveAnimDict(anim[1])
    subcaption = ''
end


local function CanDeleteChar()
    if #chars == 1 then return false end
    local deletedChars = 0
    for _, v in next, chars do
        if v.deleted then
            deletedChars = deletedChars + 1
        end    
    end

    if #chars - deletedChars <= 1 then return false end

    return true
end

local function DeleteChar()
    if not chars[currentSelectedSlot] then return end
    if chars[currentSelectedSlot]?.deleted then return end
    
    if CanDeleteChar() then
        local alert = lib.alertDialog({
            header = 'Excluir Personagem',
            content = ('Solicitar a exclusão do personagem %s %s?'):format(chars[currentSelectedSlot].firstname,
                chars[currentSelectedSlot].lastname),
            cancel = true,
            centered = true,
        })

        if alert == 'confirm' then
            lib.callback('multichar:server:deleteChar', false, function(result)
                if not result then
                    return lib.notify({
                        type = 'info',
                        alignIcon = 'top',
                        title = 'Falha na solicitação de exclusão do personagem, busque suporte no discord.',
                    })
                end

                SetCharAsDeleted( currentSelectedSlot )
            end, chars[currentSelectedSlot].id)            
        end
    else
        lib.notify({
            type = 'info',
            alignIcon = 'top',
            title = 'Você não pode excluir o único personagem.',
        })
    end
end

local function SelectChar()
    if not chars[currentSelectedSlot] then
        local alert = lib.alertDialog({
            header = 'Novo Personagem',
            content = 'Criar um novo personagem?',
            centered = true,
            cancel = true
        })

        if alert == 'confirm' then
            DeletePreviewPeds()
            CreateNewPlayerScreenRegister()
        end
    else
        local alert = lib.alertDialog({
            header = 'Logar',
            content = ('Entrar com %s %s?'):format(chars[currentSelectedSlot].firstname,
                chars[currentSelectedSlot].lastname),
            centered = true,
            cancel = true
        })

        if alert == 'confirm' then
            isloading = false
            lib.callback('multichar:server:login', false, function(_, info)
                lib.print.info('info', info)
                PreSpawn()
                exports.sw_appearance:setPlayerAppearance(chars[currentSelectedSlot].skin)
                if not info then
                    CreateSpawnMenu()
                else
                    SpawnPlayer(info.pos.x, info.pos.y, info.pos.z, info.home)
                end
            end, chars[currentSelectedSlot].id)
        end
    end
end

local function StartSelectionThread()
    local marker = lib.marker.new({
        coords = GetEntityCoords(selectedPed) - vector3(0.0, 0.0, 1.0),
        type = "VerticalCylinder",
        -- bobUpAndDown = true,
        rotate = true,
        color = { a = 175, b = 85, g = 45, r = 150 },
        height = 1.5,
        width = 1.0,
    })

    local txd = CreateRuntimeTxd("deleted_txd")    
    local tex = CreateRuntimeTextureFromImage(txd, "deleted", "assets/deleted.jpg")

    
    CreateThread(function()
        while inCharCreator do
            marker:draw()
    
            if chars[currentSelectedSlot]?.deleted then
                if tex then
                    DrawSprite('deleted_txd', 'deleted', 0.5, 0.85, 0.15, 0.15, 0.0, 255, 255, 255, 255)
                end
            end

            if IsDisabledControlJustPressed(0, 174) then --left
                if not isCamTransiting then
                    if currentSelectedSlot - 1 == 0 then
                        currentSelectedSlot = config.max_character_slots
                    else
                        currentSelectedSlot = currentSelectedSlot - 1
                    end
                    selectedPed = previewPeds[currentSelectedSlot]
                    marker.coords = GetEntityCoords(selectedPed) - vector3(0.0, 0.0, 1.0)
                    UpddateSelectionCam()
                    UpdateSubcaptionText()
                end
            end

            if IsDisabledControlJustPressed(0, 175) then --left
                if not isCamTransiting then
                    if currentSelectedSlot + 1 > config.max_character_slots then
                        currentSelectedSlot = 1
                    else
                        currentSelectedSlot = currentSelectedSlot + 1
                    end
                    print(currentSelectedSlot)
                    selectedPed = previewPeds[currentSelectedSlot]
                    marker.coords = GetEntityCoords(selectedPed) - vector3(0.0, 0.0, 1.0)
                    UpddateSelectionCam()
                    UpdateSubcaptionText()
                end
            end

            if IsDisabledControlJustPressed(0, 178) then -- delete
                if not isCamTransiting then
                    DeleteChar()
                end
            end

            if IsDisabledControlJustPressed(0, 191) then
                if not isCamTransiting then
                    SelectChar()
                end
            end

            Wait(0)
        end
    end)
end

local function CreateSelectionScene()    
    local maxslots = config.max_character_slots
    for i = 1, maxslots do
        local char = chars[i]
        CreatePedSlot(i, char)
        if char?.deleted then
            SetCharAsDeleted(i)
        end
    end
    selectedPed = previewPeds[1]
    currentSelectedSlot = 1
    StartSelectionThread()
    Wait(500)
    UpddateSelectionCam()
    UpdateSubcaptionText()
    StartTextThread()
    Wait(500)
    isloading = false
end

local function RequestCharsInfo()
    loadingMessage = 'Buscando Personagens...'
    lib.callback('multichar:server:requestCharsInfo', false, function(max, result)
        --teste

        chars = result
        if #result == 0 then
            CreateNewPlayerScreenRegister()
        elseif #result == 1 and #result >= max then
            isloading = false
            DoScreenFadeOut(0)
            if lib.callback.await('multichar:server:login', false, result[1].id) then
                PreSpawn()
                exports.sw_appearance:setPlayerAppearance(result[1].skin)
                currentSelectedSlot = 1
                CreateSpawnMenu()
            end
        else
            CreateSelectionScene()
        end
    end)
end

CreateThread(function()
    lib.hideContext()
    lib.hideMenu()
    lib.hideRadial()
    lib.hideTextUI()
    DoScreenFadeOut(0)
    while not NetworkIsPlayerActive(PlayerId()) do Wait(0) end
    NetworkStartSoloTutorialSession()
    while NetworkIsTutorialSessionChangePending() do Wait(0) end
    local pos = config.player_location
    exports.spawnmanager:spawnPlayer({
        x = pos.x,
        y = pos.y,
        z = pos.z,
        heading = 0.0,
        skipFade = true,
        model = `mp_m_freemode_01`,
    }, function()
        Wait(250)
        local ped = PlayerPedId()
        ShutdownLoadingScreenNui()
        ShutdownLoadingScreen()
        FreezeEntityPosition(ped, true)
        SetEntityVisible(ped, false, false)
        DoScreenFadeIn(0)
        StartPreviewCam()
        Wait(0)
        StartLoadingThread()
        -- StartFreezeTimeThread()
        Wait(250)
        RequestCharsInfo()
    end)
end)