---@diagnostic disable: missing-parameter, param-type-mismatch
lib.locale()

local Await <const> = Citizen.Await

local config = MulticharConfig
local cam1
local cam2
local charList
local last_selected_char = -1
local in_char_creator = true
local max_allowed = 1

CreateThread(function()
    LocalPlayer.state:set('isLoggedIn', false, true)
    LocalPlayer.state.canEmote = false
    TriggerServerEvent('vrp:player:ready', false)
    while in_char_creator do
        HideHudAndRadarThisFrame()
        DisableAllControlActions(0)
        DisableAllControlActions(1)
        Wait(0)
    end
end)

local function SpawnPlayer(x, y, z, heading, oldcam)
    in_char_creator = false
    heading = heading or 0.0
    if not IsScreenFadedIn() then DoScreenFadeIn(0) end
    local ped = PlayerPedId()
    ClearPedTasksImmediately(ped)
    SetEntityCoordsNoOffset(ped, x, y, z, false, false, true)
    SetEntityHeading(ped, heading)
    -- local fw = GetEntityForwardVector(ped) * 2
    local offsetCam = GetOffsetFromEntityInWorldCoords(ped, 0.0, 5.0, 0.0)
    local rot = GetEntityHeading(ped)
    local camx = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', offsetCam --[[vec3(x, y, z) + fw]], vec3(0.0, 0.0, rot), 55.0, false, 2)
    -- SetGameplayCamRelativeHeading(rot)
    -- SetFollowPedCamViewMode(1)
    SetCamActiveWithInterp(camx, oldcam, 2000, 16, 8)
    while IsCamInterpolating(camx) do Wait(0) end
    Wait(1000)

    RenderScriptCams(false, true, 1000, true, true)
    SetGameplayCamRelativeHeading(0.0)
    if DoesCamExist(camx) then
        SetCamActive(camx, false)
        DestroyCam(camx)
    end

    if DoesCamExist(oldcam) then DestroyCam(oldcam) end
    ClearFocus()
    LocalPlayer.state:set('isLoggedIn', true, true)
    TriggerServerEvent('vrp:player:ready', true)
    FreezeEntityPosition(ped, false)
    ClearPedTasksImmediately(ped)
    LocalPlayer.state.canEmote = true
    cam1 = nil
    cam2 = nil
    charList = {}
    last_selected_char = -1
    max_allowed = 1
    Wait(1000)
    ClearPedTasksImmediately(PlayerPedId())
    FreezeEntityPosition(PlayerPedId(), false)
    
end

local function CreateSpawnMenu()
    local char = charList[last_selected_char]
    local pos = char?.last_location
    local options = {}
    local lastOptionSelected
    if pos then
        options[#options + 1] = { label = locale('last_location'), args = { vec4(pos.x, pos.y, pos.z, 0.0) } }
    end

    for _, info in next, config.spawn_coords or {} do
        local spawnpos = info.pos
        local spawntitle = info.title
        options[#options + 1] = { label = spawntitle, args = { spawnpos } }
    end
    local spawnpos = options[1].args[1]
    local camx = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', spawnpos.x, spawnpos.y, spawnpos.z + 150.0,
        vec3(-75.0, 0.0, 0.0), 55.0, true, 2)
    if IsScreenFadedOut() then DoScreenFadeIn(100) end
    lib.registerMenu({
        id = 'spawn_menu',
        title = locale('select_spawn'),
        canClose = false,
        disableInput = true,
        position = 'top-left',
        options = options,
        onSelected = function(selected, _, args, _)
            if lastOptionSelected ~= selected then
                lastOptionSelected = selected
                SetCamCoord(camx, args[1].x, args[1].y, args[1].z + 150.0)
                SetFocusPosAndVel(args[1].x, args[1].y, args[1].z, 0.0, 0.0, 0.0)
            end
        end
    }, function(_, _, args)
        SpawnPlayer(args[1].x, args[1].y, args[1].z, args[1].w, camx)
    end)
    lib.showMenu('spawn_menu')
    ClearFocus()
    RenderScriptCams(true, false, 0, true, true)
end

local function CreateNewPlayerScreenRegister()
    local pp = config.spawn_preview
    local cc1 = config.spawn_cam_top
    local cc2 = config.spawn_cam_forward
    cam1 = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', cc1.pos, cc1.rot, cc1.fov, true, 2)
    cam2 = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', cc2.pos, cc2.rot, cc2.fov, false, 2)
    FreezeEntityPosition(cache.ped, true)
    SetEntityCoordsNoOffset(cache.ped, pp.x, pp.y, pp.z, false, false, true)
    SetEntityHeading(cache.ped, pp.w)
    ClearPedTasksImmediately(cache.ped)
    ClearFocus()
    local finished_register = promise.new()
    RenderScriptCams(true, true, 500, true, true)
    local xchar_id
    CreateThread(function()
        DoScreenFadeIn(1000)
        Wait(1000)
        while true do
            local input = lib.inputDialog(locale('register_menu_title'), {
                { type = 'input', label = locale('firstname'), required = true,              min = 4,         max = 20,              default = 'Marcos' },
                { type = 'input', label = locale('lastname'),  required = true,              min = 4,         max = 20,              default = 'Matheus' },
                { type = 'date',  label = locale('birthdate'), icon = { 'far', 'calendar' }, required = true, format = "DD/MM/YYYY", default = '2000/02/02' }
            }, { allowCancel = false })

            if input then
                local fistname = input[1]
                local lastname = input[2]
                local date = input[3]

                local created, message, char_id = lib.callback.await('multichar:server:createchar', false, fistname,
                    lastname,
                    date)

                lib.notify({
                    position = 'top',
                    duration = 5000,
                    title = message,
                    type = created and 'success' or 'error',
                    style = {
                        zoom = '1.5'
                    }
                })

                xchar_id = char_id
                finished_register:resolve(true)
                break
            end


            Wait(1000)
        end
    end)
    Await(finished_register)
    SetCamActiveWithInterp(cam2, cam1, 3000, 450, 150)
    while IsCamInterpolating(cam2) do Wait(0) end
    SetCamActive(cam1, false)
    DestroyCam(cam1, true)
    cam1 = cam2
    cam2 = nil
    Wait(500)
    RenderScriptCams(false, false, 0, true, true)
    SetCamActive(cam1, false)
    DestroyCam(cam1, true)
    cam1 = nil
    local config = {
        ped = true,
        headBlend = true,
        faceFeatures = true,
        headOverlays = true,
        components = true,
        props = true,
        allowExit = false,
        tattoos = true
    }
    exports['fivem-appearance']:startPlayerCustomization(function(appearance)
        if (appearance) then
            TriggerServerEvent('vrp:server:updatePlayerAppearance', xchar_id, appearance)
            Wait(0)
            ClearFocus()
            in_char_creator = false
            LocalPlayer.state:set('isLoggedIn', true, true)
            TriggerServerEvent('vrp:player:ready', true)
            LocalPlayer.state.canEmote = true
            FreezeEntityPosition(PlayerPedId(), false)
        end
    end, config)
end

--@#MENU DE SELEÇÃO DO PERSONAGEM
local function CreateSelectCharacterMenu()
    local pp = config.spawn_preview
    FreezeEntityPosition(cache.ped, true)
    SetEntityCoordsNoOffset(cache.ped, pp.x, pp.y, pp.z, false, false, true)
    SetEntityHeading(cache.ped, pp.w)
    ClearPedTasksImmediately(cache.ped)
    Wait(100)
    SetFocusPosAndVel(pp.x, pp.y, pp.z, 0.0, 0.0, 0.0)
    RequestCollisionAtCoord(pp.x, pp.y, pp.z)
    local timeout = GetGameTimer() + 5000
    while not HasCollisionLoadedAroundEntity(cache.ped) and GetGameTimer() < timeout do Wait(10) end
    local cc1 = config.spawn_cam_forward
    cam1 = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', cc1.pos, cc1.rot, cc1.fov, true, 2)
    RenderScriptCams(true, true, 1000, true, true)
    local options = {}
    if #charList < max_allowed then
        options[#options + 1] = { label = locale('new_char'), args = { id = 'NEW_CHAR' } }
    end

    for k, info in next, charList do
        options[#options + 1] = { label = ('[#%d] - %s %s'):format(info.id, info.firstname, info.lastname), args = { id = info.id, index = k } }
    end

    if not IsScreenFadedIn() then
        DoScreenFadeIn(1000)
        Wait(1250)
    end

    lib.hideMenu()

    lib.registerMenu({
        id = 'selector_menu',
        title = 'Selector Menu',
        position = 'top-left',
        disableInput = true,
        options = options,
        canClose = false,
        onSelected = function(_, _, args, _)
            if args.id == 'NEW_CHAR' then return end
            local currentChar = charList[args.index]
            if last_selected_char ~= args.index then
                last_selected_char = args.index
                if currentChar?.custom?.model then
                    exports['fivem-appearance']:setPlayerAppearance(currentChar.custom)
                else
                    local model = lib.requestModel(`mp_m_freemode_01`, 10000)
                    SetPlayerModel(cache.playerId, model)
                    cache.ped = PlayerPedId()
                    SetPedDefaultComponentVariation(cache.ped)
                    SetEntityVisible(cache.ped, true, false)
                end
                cache.ped = PlayerPedId()
                local anim = config.spawn_preview_anims[math.random(1, #config.spawn_preview_anims)]
                lib.requestAnimDict(anim.dict)
                TaskPlayAnim(cache.ped, anim.dict, anim.name, 4.0, -4.0, -1, 1, 0.0, false, false, false)
                RemoveAnimDict(anim.dict)
            end
        end
    }, function(_, _, args)
        if args?.id == 'NEW_CHAR' then
            DoScreenFadeOut(500)
            Wait(1000)
            CreateNewPlayerScreenRegister()
        else
            ClearPedTasksImmediately(PlayerPedId())

            if lib.callback.await('multichar:server:login', false, args.id) then
                CreateSpawnMenu()
            end
        end
    end)

    lib.showMenu('selector_menu')
end


local function RequestCharsInfo()
    lib.callback('multichar:server:requestCharsInfo', false, function(max_allowed_chars, chars)
        max_allowed = max_allowed_chars
        charList = chars
        if #chars == 0 then
            local model = lib.requestModel(`mp_m_freemode_01`, 10000)
            SetPlayerModel(cache.playerId, model)
            Wait(100) -- mandatory wait
            cache.ped = PlayerPedId()
            SetPedDefaultComponentVariation(cache.ped)
            SetEntityVisible(cache.ped, true)
            CreateNewPlayerScreenRegister()
        elseif #charList == 1 and #charList >= max_allowed then
            last_selected_char = 1
            local character = charList[last_selected_char]
            if character?.custom?.model then
                exports['fivem-appearance']:setPlayerAppearance(character.custom)
            end
            CreateSpawnMenu()
        else
            CreateSelectCharacterMenu()
        end
    end)
end


local spawned = false

AddEventHandler('playerSpawned', function()
    print('playerSpawned')
    spawned = true
end)

CreateThread(function()
    ClearFocus()
    DoScreenFadeOut(0)
    lib.hideContext()
    lib.hideRadial()
    lib.hideTextUI()
    lib.hideMenu()
    local timeout = GetGameTimer() + 30000
    while true do
        if not IsScreenFadedOut() then DoScreenFadeOut(0) end
        if NetworkIsPlayerActive(cache.playerId) then
            if spawned or GetGameTimer() > timeout then break end
        end
        Wait(50)
    end
    if not IsScreenFadedOut() then DoScreenFadeOut(0) end
    Wait(2000)
    print('OK-REQUEST INFO')
    RequestCharsInfo()
end)

RegisterCommand('debugc', function(source, args, raw)
    spawned = true
end)
