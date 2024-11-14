local config = BeatyConfig
local zones = {}
local pedZones = {}

local isOpen = false
local old_appareance = nil

local STORE_CONFIG <const> = {
    [1] = {
        ped = false,
        headBlend = false,
        faceFeatures = false,
        headOverlays = false,
        components = true,
        props = true,
        allowExit = true,
        tattoos = false,
        allowSavePreset = config.allowed_save_preset,
        presetPrice = config.save_preset_price
    },
    [2] = {
        ped = false,
        headBlend = false,
        faceFeatures = false,
        headOverlays = true,
        components = false,
        props = false,
        allowExit = true,
        tattoos = false
    },
    [3] = {
        ped = false,
        headBlend = false,
        faceFeatures = false,
        headOverlays = false,
        components = false,
        props = false,
        allowExit = true,
        tattoos = true
    },

}


local function addStoreBlip(store)
    local blip = AddBlipForCoord(store.location)
    SetBlipSprite(blip, store?.blip?.icon or 0)
    SetBlipColour(blip, store?.blip.color or 0)
    SetBlipScale(blip, store?.blip?.size or 0.5)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(store.label)
    EndTextCommandSetBlipName(blip)
end

local function createStoreTargetZone(store)
    if not store?.zone then return end
    zones[#zones + 1] = exports.ox_target:addBoxZone({
        name = 'shop_' .. #zones,
        coords = store.zone.coord,
        rotation = store.zone.heading,
        drawSprite = false,
        size = store.zone.size,
        debug = false,
        options = {
            {
                label = locale('open_shop'),
                icon = store.zone.icon,
                event = 'beatyshop:client:open',
                distance = 3.0,
                heading = store.zone.heading,
                type = store.type
            }
        }
    })
end


local function createStoreTargetEntity(store)
    CreateThread(function()
        if not store?.ped then return end
        local pedInfo = store.ped
        local model = lib.requestModel(pedInfo.model, 60000)
        local pos = pedInfo.pos
        local ped = CreatePed(24, model, pos.x, pos.y, pos.z, pos.w, false, true)
        SetPedRandomComponentVariation(ped, 0)
        SetPedRandomProps(ped)
        SetEntityInvincible(ped, true)
        SetPedCanBeTargetted(ped, false)
        SetPedCanBeTargettedByPlayer(ped, PlayerId(), false)
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetEntityCoordsNoOffset(ped, pos.x, pos.y, pos.z + 0.05, false, false, true)
        SetEntityHeading(ped, pos.w)
        SetEntityHealth(ped, 200)
        if pedInfo.anim?.dict and pedInfo.anim?.name then
            lib.requestAnimDict(pedInfo.anim.dict)
            TaskPlayAnim(ped, pedInfo.anim.dict, pedInfo.anim.name, 4.0, -4.0, -1, 17, 0.0, false, false, false)
            RemoveAnimDict(pedInfo.anim?.dict)
        end
        Wait(1000)
        FreezeEntityPosition(ped, true)
        SetModelAsNoLongerNeeded(model)
        pedZones[#pedZones + 1] = exports.ox_target:addLocalEntity(ped, {
            {
                label = locale('open_shop'),
                icon = store.ped.icon,
                event = 'beatyshop:client:open',
                distance = 3.0,
                heading = pos.w,
                type = store.type
            }
        })        
    end)
end

AddEventHandler('beatyshop:client:open', function(data)
    lib.print.info(data)
    if not data then return end
    if isOpen then return end
    if data.distance > 3.0 then return end
    if not data.type then return error(locale('store_type_not_found')) end
    local sconfig = STORE_CONFIG[data.type]    
    SetEntityHeading(cache.ped, data.heading)

    if data.type ~= 1 then
        SetEntityVisible(data.entity, false, true)
    end
    NetworkSetEntityInvisibleToNetwork(PlayerPedId(), true)
    LocalPlayer.state.not_save_custom = true
    old_appareance = exports.sw_appearance:getPedAppearance(PlayerPedId())
    exports.sw_appearance:startPlayerCustomization(function(app)


        LocalPlayer.state.not_save_custom = nil        
        NetworkSetEntityInvisibleToNetwork(PlayerPedId(), false)
        if data.type ~= 1 then
            SetEntityVisible(data.entity, true, true)
        end
        if not app then return end

        if app.is_preset then
            if (vRP.getPlayer()?.money?.cash or 0 )>= config.save_preset_price then
                vRP.notify('Loja', 'Preset adicionado a sua mochila.', 5000, 'success') 
                TriggerServerEvent('beaty:savepreset', app.preset)
            else
                vRP.notify('Loja', 'Você não possui dinheiro suficiente.', 5000, 'error') 
            end
            return
        end
        if (vRP.getPlayer()?.money?.cash or 0 ) >= 500 then
            TriggerServerEvent('beaty:checkpayment')        
        else
            exports.sw_appearance:setPedAppearance(PlayerPedId(), old_appareance)
            vRP.notify('Loja', 'Você não possui dinheiro suficiente.', 5000, 'error')            
        end
        old_appareance = nil
    end, sconfig, true, false)
end)

CreateThread(function()
    for _, store in next, config?.stores or {} do
        addStoreBlip(store)
        if store.type == 1 then
            createStoreTargetZone(store)
        else            
            createStoreTargetEntity(store)
        end
    end
end)


AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for _, v in next, zones or {} do
        exports.ox_target:removeZone(v, false)
    end
    exports.ox_target:removeLocalEntity(pedZones)
end)


--ex inventory item
exports('preset', function(data, slot)
    lib.print.info(data, slot)
    if not slot?.metadata?.preset_id then return end

    local preset = GetResourceKvpString(slot.metadata.preset_id)
    if not preset then
        preset = lib.callback.await('beaty:server:getPreset', false, slot?.metadata?.preset_id)
        
        if not preset then return end
        local dict = 'clothingtie'
        pcall(lib.requestAnimDict, dict)
        if HasAnimDictLoaded(dict) then
           TaskPlayAnim(cache.ped, dict, 'try_tie_negative_a', 8.0, -8.0, 600, 51, 0.0, false, false, false) 
           RemoveAnimDict(dict)
        end
       
        SetResourceKvp(slot.metadata.preset_id, json.encode(preset))
        exports.sw_appearance:setPedComponents(PlayerPedId(), preset.components)
        exports.sw_appearance:setPedProps(PlayerPedId(), preset.props)
    end
end)
