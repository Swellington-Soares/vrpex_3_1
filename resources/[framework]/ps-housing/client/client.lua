local loaded = false


local function createProperty(property)
    PropertiesTable[property.property_id] = Property:new(property)
end

RegisterNetEvent('ps-housing:client:addProperty', createProperty)

RegisterNetEvent('ps-housing:client:removeProperty', function(property_id)
    local property = Property.Get(property_id)

    if property then
        property:RemoveProperty()
    end

    PropertiesTable[property_id] = nil
end)

function InitialiseProperties(properties)
    if loaded then return end
    Debug("Initialising properties")
    
    -- lib.callback('vrp:server:getPlayerData', false, function(result)
    --     PlayerData = result or {}
    -- end)
    PlayerData = vRP.getPlayer()

    for k, v in pairs(Config.Apartments) do
        ApartmentsTable[k] = Apartment:new(v)
    end

    if not properties then
        properties = lib.callback.await('ps-housing:server:requestProperties')
    end

    for k, v in pairs(properties) do        
        createProperty(v.propertyData)
    end

    TriggerEvent("ps-housing:client:initialisedProperties")

    Debug("Initialised properties")
    loaded = true
end

AddEventHandler("playerReady", InitialiseProperties)

RegisterNetEvent('ps-housing:client:initialiseProperties', InitialiseProperties)

-- AddEventHandler("onResourceStart", function(resourceName) -- Used for when the resource is restarted while in game
-- 	if (GetCurrentResourceName() == resourceName) then
--         InitialiseProperties()
-- 	end
-- end)

RegisterNetEvent('vRP:updateGroupInfo', function(group)
    PlayerData = PlayerData or {}
    if group?.type == 'job' then
        PlayerData.job = PlayerData.job or {}
        if group.action == 'enter' and group?.duty then
            PlayerData.job = { name = group, rank = group.rank, onduty = true }
        else
            PlayerData.job = { name = "", rank = 0, onduty = false }
        end
    end
end)

AddEventHandler("onResourceStop", function(resourceName)
    if (GetCurrentResourceName() == resourceName) then
        if Modeler.IsMenuActive then
            Modeler:CloseMenu()
        end

        for k, v in pairs(PropertiesTable) do
            v:RemoveProperty()
        end

        for k, v in pairs(ApartmentsTable) do
            v:RemoveApartment()
        end
    end
end)

exports('GetProperties', function()
    return PropertiesTable
end)

exports('GetProperty', function(property_id)
    return Property.Get(property_id)
end)

exports('GetApartments', function()
    return ApartmentsTable
end)

exports('GetApartment', function(apartment)
    return Apartment.Get(apartment)
end)

exports('GetShells', function()
    return Config.Shells
end)


lib.callback.register('ps-housing:cb:confirmPurchase', function(amount, street, id)
    return lib.alertDialog({
        header = locale("purchase_alert.header"),
        content = locale("purchase_alert.message", street, id, amount),
        centered = true,
        cancel = true,
        labels = {
            confirm = locale("alert.purchase"),
            cancel = locale("alert.cancel")
        }
    })
end)

lib.callback.register('ps-housing:cb:confirmRaid', function(street, id)
    return lib.alertDialog({
        header = locale("alert.raid"),
        content = locale("raid_alert.message", street, id),
        centered = true,
        cancel = true,
        labels = {
            confirm = locale("alert.raid"),
            cancel = locale("alert.cancel")
        }
    })
end)

lib.callback.register('ps-housing:cb:ringDoorbell', function()
    return lib.alertDialog({
        header = locale("alert_ring_door.header"),
        content = locale("alert_ring_door.message"),
        centered = true,
        cancel = true,
        labels = {
            confirm = locale("alert.ring"),
            cancel = locale("alert.cancel")
        }
    })
end)

lib.callback.register('ps-housing:cb:showcase', function()
    return lib.alertDialog({
        header = locale("alert_showcase.header"),
        content = locale("alert_showcase.header"),
        centered = true,
        cancel = true,
        labels = {
            confirm = locale("alert.yes"),
            cancel = locale("alert.cancel")
        }
    })
end)
