local showHud = true
local cinematic = false

local HUD = {
    hunger = 0,
    thirst = 0,
    stress = 0,
}


local function GetMinimapAnchor()
    -- Safezone goes from 1.0 (no gap) to 0.9 (5% gap (1/20))
    -- 0.05 * ((safezone - 0.9) * 10)
    local safezone = GetSafeZoneSize()
    local safezone_x = 1.0 / 20.0
    local safezone_y = 1.0 / 20.0
    local aspect_ratio = GetAspectRatio(false)
    local res_x, res_y = GetActiveScreenResolution()
    local xscale = 1.0 / res_x
    local yscale = 1.0 / res_y
    local Minimap = {}
    Minimap.width = xscale * (res_x / (4 * aspect_ratio))
    Minimap.height = yscale * (res_y / 5.674)
    Minimap.left_x = xscale * (res_x * (safezone_x * ((math.abs(safezone - 1.0)) * 10)))
    Minimap.bottom_y = 1.0 - yscale * (res_y * (safezone_y * ((math.abs(safezone - 1.0)) * 10)))
    Minimap.right_x = Minimap.left_x + Minimap.width
    Minimap.top_y = Minimap.bottom_y - Minimap.height
    Minimap.x = Minimap.left_x
    Minimap.y = Minimap.top_y
    Minimap.xunit = xscale
    Minimap.yunit = yscale
    return Minimap
end

local function ShowCinematic()
    CreateThread(function()
        local y = 0.0
        local hudState = showHud
        while cinematic do
            showHud = false
            HideHudAndRadarThisFrame()
            while y < 0.3 and cinematic do
                y = y + 0.0025
                HideHudAndRadarThisFrame()
                DrawRect(0.5, 0.0, 1.0, y, 0, 0, 0, 255)
                DrawRect(0.5, 1.0, 1.0, y, 0, 0, 0, 255)
                Wait(0)
            end
            DrawRect(0.5, 0.0, 1.0, 0.3, 0, 0, 0, 255)
            DrawRect(0.5, 1.0, 1.0, 0.3, 0, 0, 0, 255)
            Wait(0)
        end
        showHud = hudState
    end)
end

RegisterCommand('hud', function()
    if not LocalPlayer.state.isLoggedIn then return end
    showHud = not showHud
end)


RegisterCommand('hudc', function()
    if not LocalPlayer.state.isLoggedIn then return end
    cinematic = not cinematic
    if cinematic then
        ShowCinematic()
    end
end)


local startColor = { r = 0, g = 0, b = 0, a = 255 } -- Cor inicial (vermelho)
local endColor = { r = 0, g = 0, b = 255, a = 255 } -- Cor final (azul)
local transitionTime = 2.0                              -- Tempo total da transição em segundos
local elapsedTime = 0                                   -- Tempo decorrido
local direction = 1

local function lerp(a, b, t)
    return a + (b - a) * t
end

local function drawRct(x, y, width, height, r, g, b, a)
    DrawRect(x + width / 2, y + height / 2, width, height, r, g, b, a)
end


--MAIN TEST THREAD
CreateThread(function()
    while true do
        if showHud then
            local ped = cache.ped
            local ui = GetMinimapAnchor()            
            local thickness = 15 -- Defines how many pixels wide the border is            
            drawRct(ui.x, ui.y - 0.070, ( ui.width * ( GetEntityHealth(ped) / GetEntityMaxHealth(ped) )) , thickness * ui.yunit, 255, 0, 0, 255)
            drawRct(ui.x, ui.y - 0.045, ( ui.width * ( GetPedArmour( ped ) / 100.0 )), thickness * ui.yunit, 0, 0, 255, 255)                      
        end
        Wait(0)
    end
end)
