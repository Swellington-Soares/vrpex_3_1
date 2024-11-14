local TextZoomLib = lib.require('client.zoomtext')

local topCam, frontCam, interiorCam

local function setupCameras(taxi)
    -- Câmera Aérea
    topCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    AttachCamToEntity(topCam, taxi, -5.0, -5.0, 5.0, true)
    SetCamRot(topCam, -45.0, 0.0, GetEntityHeading(taxi))
    
    -- Câmera Frontal
    frontCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    AttachCamToEntity(frontCam, taxi, 2.5, 0.0, 1.0, true)
    SetCamRot(frontCam, 0.0, 0.0, GetEntityHeading(taxi) + 180.0)
    
    -- Câmera Interna
    interiorCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    AttachCamToEntity(interiorCam, taxi, 0.0, 2.0, 1.0, true)
    SetCamRot(interiorCam, 0.0, 0.0, GetEntityHeading(taxi) - 180.0)
end

local function transitionToCamera(fromCam, toCam, transitionTime)
    SetCamActiveWithInterp(toCam, fromCam, transitionTime, true, true)
end


local function taxiCameraSequence()
    -- Iniciar com a câmera aérea
    SetCamActive(topCam, true)
    RenderScriptCams(true, true, 2000, true, true)
    Wait(15000) -- Duração da vista aérea
    
    -- Transição para a câmera frontal
    transitionToCamera(topCam, frontCam, 3000)
    Wait(15000) -- Duração da vista frontal após a transição

    -- Transição para a câmera interna
    transitionToCamera(frontCam, interiorCam, 3000)
    Wait(7000) -- Duração da vista interna após a transição

    transitionToCamera(interiorCam, frontCam, 3000)
    Wait(5000)

    transitionToCamera(topCam, frontCam, 3000)
    Wait(3000)

    -- Retornar à câmera normal do jogador
    RenderScriptCams(false, true, 2000, true, true)
end

-- Execute a sequência de câmeras no táxi




function RunIntro()
    local ped = PlayerPedId()
    local taxiModel = lib.requestModel('taxi')
    local driverModel = lib.requestModel('a_m_m_prolhost_01')
    local pos = vec4(-869.73, -546.5, 21.66, 281.7)
    local destiny = vec4(112.73, -947.21, 29.16, 158.78)
    local taxi = CreateVehicle(taxiModel, pos.x, pos.y, pos.z, pos.w, false, true)
    local driver = CreatePedInsideVehicle(taxi, 4, driverModel, -1, false, true)
    SetVehicleBodyHealth(taxi, 1000.0)
    SetVehicleEngineCanDegrade(taxi, false)
    SetVehicleEngineOn(taxi, true, true, false)
    SetPedIntoVehicle(ped, taxi, 2)
    Wait(0)
    -- TaskVehicleDriveToCoord(driver, taxi, destiny.x, destiny.y, destiny.z, 50.0, 1.0, 'taxi', 447, 1.0, 0.0)
    TaskVehicleDriveToCoordLongrange(driver, taxi, 
    destiny.x, destiny.y, destiny.z, 40.0, 16384, 20.0);
    Wait(1000)
    CreateThread(function()
        TextZoomLib.zoomInText("Bem-vindo a ~g~Maré ~b~Nova ~y~RJ~s~", 0.01, 2.0, 0.01, 8000)
        Wait(8000)
        TextZoomLib.zoomOutText("Bem-vindo a ~g~Maré ~b~Nova ~y~RJ~s~", 2.0, 0.01, 0.01, 500)

        TextZoomLib.zoomInText("Respeite as ~r~Regras~s~", 0.01, 2.0, 0.01, 8000)
        Wait(8000)
        TextZoomLib.zoomOutText("Respeite as ~r~Regras~s~", 2.0, 0.01, 0.01, 500)

        TextZoomLib.zoomInText("Faça um bom ~b~Roleplay~s~", 0.01, 2.0, 0.01, 8000)
        Wait(8000)
        TextZoomLib.zoomOutText("Faça um bom ~b~Roleplay~s~", 2.0, 0.01, 0.01, 500)

        TextZoomLib.zoomInText("Temos muitas ~y~oportunidades~s~", 0.01, 2.0, 0.01, 8000)
        Wait(8000)
        TextZoomLib.zoomOutText("Temos muitas ~y~oportunidades~s~", 2.0, 0.01, 0.01, 500)

        TextZoomLib.zoomInText("Seja ~g~criativo!~g~", 0.01, 2.0, 0.01, 8000)
        Wait(8000)
        TextZoomLib.zoomOutText("Seja ~g~criativo!~g~", 2.0, 0.01, 0.01, 500)

        TextZoomLib.zoomInText("Suporte? Procure nosso ~q~Discord~s~", 0.01, 2.0, 0.01, 8000)
        Wait(8000)
        TextZoomLib.zoomOutText("Suporte? Procure nosso ~q~Discord~s~", 2.0, 0.01, 0.01, 500)
        DoScreenFadeOut(3500)
        while not IsScreenFadedOut() do Wait(0) end
        Wait(2000)
        DoScreenFadeIn(0)
    end) 
    setupCameras(taxi)
    taxiCameraSequence()
             
end



RegisterCommand('intro', function (source, args, raw)
    RunIntro()
end)