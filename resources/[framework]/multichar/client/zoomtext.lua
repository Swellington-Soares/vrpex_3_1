-- Definição do módulo de efeitos de zoom
local TextZoomLib = {}

-- Função para desenhar o texto com um determinado tamanho
local function drawText(text, scale)
    SetTextFont(4) -- Fonte legível
    SetTextScale(scale, scale) -- Tamanho do texto
    SetTextColour(255, 255, 255, 255) -- Cor branca e opaca
    SetTextCentre(true) -- Centraliza o texto
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(0.5, 0.5) -- Exibe no centro da tela
end

-- Função de zoom-in (texto cresce)
function TextZoomLib.zoomInText(text, startScale, endScale, speed, timeout)
    local t = GetGameTimer() + timeout
    Citizen.CreateThread(function()
        local scale = startScale

        while scale < endScale do
            drawText(text, scale)
            scale = scale + speed
            Wait(0) -- Garante que será chamado a cada frame
        end

        while true do
            Wait(0)
            drawText(text, scale)
            if GetGameTimer() > t then break end            
        end
    end)
end

-- Função de zoom-out (texto diminui)
function TextZoomLib.zoomOutText(text, startScale, endScale, speed, timeout)
    local t = GetGameTimer() + timeout
    Citizen.CreateThread(function()
        local scale = startScale

        while GetGameTimer() < t do
            drawText(text, scale)
            Wait(0)
        end

        while scale > endScale do
            drawText(text, scale)
            scale = scale - speed
            Wait(0) -- Garante que será chamado a cada frame
        end
    end)
end

return TextZoomLib
