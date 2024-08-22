---@diagnostic disable: missing-parameter, param-type-mismatch
lib.locale()
local config = MulticharConfig
local cam1
local cam2
local _charList
local last_selected_char = -1
local in_char_creator = true

local function CreateSpawnMenu()
    local character = _charList[last_selected_char]
    lib.print.info('LAST SELECTED', json.encode(character))
    if character then
        local cams = {}
        local pos = character?.database?.position or vec3(0.0, 0.0, 0.0)
        local options = {}
        local lastOptionSelected
        if #pos > 0 then
            options[#options + 1] = { label = locale('last_location'), args = { vec3(pos.x, pos.y, pos.z) } }
        end

        for _, spawnloc in next, config.spawn_coords or {} do
            options[#options + 1] = { label = spawnloc.title, args = { spawnloc.pos } }
        end

        for k, p in next, options do
            cams[k] = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', p.args[1].x, p.args[1].y, p.args[1].z + 150.0,
                vec3(-75.0, 0.0, 0.0), 55.0, false, 2)
        end

        RenderScriptCams(true, false, 0, true, true)
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
                    SetCamActive(cams[selected], true)
                    SetFocusPosAndVel(args[1].x, args[1].y, args[1].z, 0.0, 0.0, 0.0)
                end
            end,
        }, function(selected, _, args)
            local pos = vec3(args[1].x, args[1].y, args[1].z)
            local ped = PlayerPedId()
            SetEntityCoordsNoOffset(ped, pos.x, pos.y, pos.z, false, false, true)
            local fw = GetEntityForwardVector(ped) * 2
            local rot = GetEntityHeading(ped)
            Wait(1000)
            cam1 = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', pos + fw, vec3(0.0, 0.0, rot), 55.0, false, 2)
            SetGameplayCamRelativeHeading(rot - 90.0)
            SetCamActiveWithInterp(cam1, cams[selected], 2000, 16, 8)
            while IsCamInterpolating(cam1) do Wait(0) end
            RenderScriptCams(false, true, 1000, true, true)
            for _, xcam in next, cams do 
                if DoesCamExist(xcam) then
                    SetCamActive(xcam, false)
                    DestroyCam(xcam, true)
                end
            end
            if DoesCamExist(cam1) then
                DestroyCam()
            end
            ClearFocus()
            in_char_creator = false
        end)

        lib.showMenu('spawn_menu')
    end
end

local function NewCharMenu()
    local pp = config.spawn_preview
    local ped = PlayerPedId()
    SetEntityCoordsNoOffset(cache.ped, pp.x, pp.y, pp.z, false, false, true)
    SetEntityHeading(ped, pp.w)
    -- FreezeEntityPosition(ped, true)
    ClearPedTasksImmediately(ped)

    if HasModelLoaded(`mp_m_freemode_01`) then SetModelAsNoLongerNeeded(`mp_m_freemode_01`) end
    if HasModelLoaded(`mp_f_freemode_01`) then SetModelAsNoLongerNeeded(`mp_f_freemode_01`) end

    local model = lib.requestModel(`mp_m_freemode_01`, 10000)

    if GetEntityModel(ped) ~= model then
        SetPlayerModel(PlayerId(), model)
        ped = PlayerPedId()
    end

    CreateThread(function()
        while in_char_creator do
            HideHudAndRadarThisFrame()
            DisableAllControlActions(0)
            DisableAllControlActions(1)
            Wait(0)
        end
    end)

    local cc1 = config.spawn_cam_top
    local cc2 = config.spawn_cam_forward
    cam1 = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', cc1.pos, cc1.rot, cc1.fov, true, 2)
    cam2 = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', cc2.pos, cc2.rot, cc2.fov, false, 2)
    RenderScriptCams(true, true, 0, true, true)
    DoScreenFadeIn(1000)
    Wait(1000)
    local xchar_id
    CreateThread(function()
        local finished_register = false
        while not finished_register do
            Wait(1000)
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

                finished_register = created
                xchar_id = char_id
            end
        end

        SetCamActiveWithInterp(cam2, cam1, 3000, 0, 0)
        while IsCamInterpolating(cam2) do
            Wait(0)
        end
        SetCamActive(cam1, false)
        DestroyCam(cam1, true)
        cam1 = cam2
        cam2 = nil
        Wait(0)
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
                Wait(0)
                SetCamActive(cam1, false)
                RenderScriptCams(false, false, 0, true, true)
                if cam1 and DoesCamExist(cam1) then DestroyCam(cam1) end
                if cam2 and DoesCamExist(cam2) then DestroyCam(cam2) end
                cam1 = nil
                cam2 = nil
                in_char_creator = false
                TriggerServerEvent('vrp:server:updatePlayerAppearance', xchar_id, appearance)
            end
        end, config)
    end)
end

local function CreateSelectorMenu()
    lib.callback('multichar:server:getCharacters', false, function(charList)
        _charList = charList
        if #_charList > 0 then
            local options = {
                { label = locale('new_char'), args = { id = 'NEW_CHAR' } },
            }

            for k, info in next, _charList do
                options[#options + 1] = { label = ('[#%d] - %s %s'):format(info.id, info.firstname, info.lastname), args = { id = info.id, index = k } }
            end

            CreateThread(function()
                while in_char_creator do
                    HideHudAndRadarThisFrame()
                    DisableAllControlActions(0)
                    DisableAllControlActions(1)
                    Wait(0)
                end
            end)


            local pp = config.spawn_preview
            local ped = PlayerPedId()
            SetEntityCoordsNoOffset(cache.ped, pp.x, pp.y, pp.z, false, false, true)
            SetEntityHeading(ped, pp.w)
            ClearPedTasksImmediately(ped)

            --update custom
            local cc1 = config.spawn_cam_forward
            cam1 = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', cc1.pos, cc1.rot, cc1.fov, true, 2)
            RenderScriptCams(true, true, 1000, true, true)
            Wait(1000)
            DoScreenFadeIn(1000)
            Wait(0)
            lib.hideMenu()

            lib.registerMenu({
                id = 'selector_menu',
                title = 'Selector Menu',
                position = 'top-left',
                disableInput = true,
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
                            SetPedDefaultComponentVariation(ped)
                            SetEntityVisible(ped, true, false)
                        end
                        cache.ped = PlayerPedId()
                        ped = PlayerPedId()
                        local anim = config.spawn_preview_anims[math.random(1, #config.spawn_preview_anims)]
                        lib.requestAnimDict(anim.dict)
                        TaskPlayAnim(ped, anim.dict, anim.name, 4.0, -4.0, -1, 1, 0.0, false, false, false)
                        RemoveAnimDict(anim.dict)
                    end
                end,
                options = options,
                canClose = false,
            }, function(_, _, args)
                if args?.id == 'NEW_CHAR' then
                    DoScreenFadeOut(0)
                    Wait(1000)
                    NewCharMenu()
                else                    
                    CreateSpawnMenu()
                end
            end)

            lib.showMenu('selector_menu')
        else
            Wait(1000)
            NewCharMenu()
        end
    end)
end

CreateThread(function()
    lib.hideMenu()
    lib.hideContext()
    lib.hideRadial()
    lib.hideTextUI()
    DoScreenFadeOut(0)
    while not NetworkIsSessionStarted() do Wait(0) end
    CreateSelectorMenu()
end)
