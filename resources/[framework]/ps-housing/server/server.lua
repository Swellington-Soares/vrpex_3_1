local dbloaded = false
MySQL.ready(function()
    MySQL.query('SELECT * FROM properties', {}, function(result)
        if not result then return end
        if result?.id then -- If only one result
            result = { result }
        end
        for _, v in pairs(result) do
            local id = tostring(v.property_id)
            local has_access = json.decode(v.has_access)
            local owner = v.owner_citizenid
            local propertyData = {
                property_id = tostring(id),
                owner = owner,
                street = v.street,
                region = v.region,
                description = v.description,
                has_access = has_access,
                extra_imgs = json.decode(v.extra_imgs),
                furnitures = json.decode(v.furnitures),
                for_sale = v.for_sale,
                price = v.price,
                shell = v.shell,
                apartment = v.apartment,
                door_data = json.decode(v.door_data),
                garage_data = json.decode(v.garage_data),
                zone_data = v.zone_data,
            }
            PropertiesTable[id] = Property:new(propertyData)

            if v.shell == 'mlo' and owner then
                local property = PropertiesTable[id]
                -- we add door access for qb doorlock
                property:addMloDoorsAccess(owner)
                if has_access and #has_access > 0 then
                    for _, citizenId in ipairs(has_access) do
                        property:addMloDoorsAccess(citizenId)
                    end
                end
            end
        end

        dbloaded = true
    end)
end)

lib.callback.register("ps-housing:server:requestProperties", function()
    while not dbloaded do
        Wait(100)
    end

    return PropertiesTable
end)

function RegisterProperty(propertyData, preventEnter, source)
    propertyData.owner = propertyData.owner or nil
    propertyData.has_access = propertyData.has_access or {}
    propertyData.extra_imgs = propertyData.extra_imgs or {}
    propertyData.furnitures = propertyData.furnitures or {}
    propertyData.door_data = propertyData.door_data or {}
    propertyData.garage_data = propertyData.garage_data or {}
    propertyData.zone_data = propertyData.zone_data or {}

    local cols =
    "(owner_citizenid, street, region, description, has_access, extra_imgs, furnitures, for_sale, price, shell, apartment, door_data, garage_data, zone_data)"
    local vals =
    "(@owner_citizenid, @street, @region, @description, @has_access, @extra_imgs, @furnitures, @for_sale, @price, @shell, @apartment, @door_data, @garage_data, @zone_data)"

    local id = MySQL.insert.await("INSERT INTO properties " .. cols .. " VALUES " .. vals, {
        ["@owner_citizenid"] = propertyData.owner or nil,
        ["@street"] = propertyData.street,
        ["@region"] = propertyData.region,
        ["@description"] = propertyData.description,
        ["@has_access"] = json.encode(propertyData.has_access),
        ["@extra_imgs"] = json.encode(propertyData.extra_imgs),
        ["@furnitures"] = json.encode(propertyData.furnitures),
        ["@for_sale"] = propertyData.for_sale ~= nil and propertyData.for_sale or 1,
        ["@price"] = propertyData.price or 0,
        ["@shell"] = propertyData.shell or '',
        ["@apartment"] = propertyData.apartment,
        ["@door_data"] = json.encode(propertyData.shell == 'mlo' and { count = #propertyData.door_data } or
            propertyData.door_data),
        ["@garage_data"] = json.encode(propertyData.garage_data),
        ["@zone_data"] = json.encode(propertyData.zone_data),
    })

    id = tostring(id)

    if source and propertyData.shell == 'mlo' then
        for _, v in ipairs(propertyData.door_data) do
            local isArray = v[1] and true
            exports.doorlock:saveNewDoor(source, {
                locked = true,
                model = isArray and { v[1].model, v[2].model } or v.model,
                heading = isArray and { v[1].heading, v[2].heading } or v.heading,
                coords = isArray and { v[1].coords, v[2].coords } or v.coords,
                distance = 2.5,
                doortype = 'door',
                id = ('ps_mloproperty%s_%s'):format(id, _)
            }, isArray)
        end

        propertyData.door_data = { count = #propertyData.door_data }
        Wait(1000)
    end

    propertyData.property_id = id
    PropertiesTable[id] = Property:new(propertyData)

    TriggerClientEvent("ps-housing:client:addProperty", -1, propertyData)

    if propertyData.apartment and not preventEnter then
        local player = vRP.getPlayerInfo(vRP.getSourceByCharacterId(tonumber(propertyData.owner)))
        if not player then return end
        local src = player?.source
        local property = Property.Get(id)
        property:PlayerEnter(src)
        Wait(1000)
        Framework[Config.Notify].Notify(src,
            "Open radial menu for furniture menu and place down your stash and clothing locker.", "info")
    end

    return id
end

local function getMainDoor(propertyId, doorIndex, isShell)
    -- ps_mloproperty is prefix, self.property_id is property unique id, 1 is main door index, cause mlo can have multiple doors

    if isShell then
        local property = Property.Get(propertyId)
        if not property then return end
        return {
            coords = property.propertyData.door_data
        }
    end

    local id = ('ps_mloproperty%s_%s'):format(propertyId, doorIndex)
    return exports.doorlock:getDoor(id)
end

exports('getMainDoor', getMainDoor)

lib.callback.register("ps-housing:cb:getMainMloDoor", function(_, propertyId, doorIndex)
    return getMainDoor(propertyId, doorIndex)
end)

exports('registerProperty', RegisterProperty) -- triggered by realtor job
AddEventHandler("ps-housing:server:registerProperty", RegisterProperty)

lib.callback.register("ps-housing:cb:GetOwnedApartment", function(source, cid)
    Debug("ps-housing:cb:GetOwnedApartment", source, cid)
    if cid ~= nil then
        return MySQL.single.await(
        'SELECT * FROM properties WHERE owner_citizenid = ? AND apartment IS NOT NULL AND apartment <> ""', { cid })
    else
        local src = source
        local citizenid = vRP.getCharaterIdBySource(src)
        return MySQL.single.await(
        'SELECT * FROM properties WHERE owner_citizenid = ? AND apartment IS NOT NULL AND apartment <> ""', { citizenid })
    end
end)

lib.callback.register("ps-housing:cb:inventoryHasItems", function(_, name)
    local items = exports.ox_inventory:GetInventoryItems(name)
    return items and items > 0
end)

AddEventHandler("ps-housing:server:updateProperty", function(type, property_id, data)
    
    local property = Property.Get(property_id)
    if not property then return end

    property[type](property, data)
end)

AddEventHandler("onResourceStart", function(resourceName) -- Used for when the resource is restarted while in game
    if (GetCurrentResourceName() == resourceName) then
        while not dbloaded do
            Wait(100)
        end
        TriggerClientEvent('ps-housing:client:initialiseProperties', -1, PropertiesTable)
    end
end)

RegisterNetEvent("ps-housing:server:createNewApartment", function(aptLabel)
    local src = source
    local citizenid = GetCitizenid(src)
    if not Config.StartingApartment then return end
    local PlayerData = GetPlayerData(src)
    if not PlayerData then return end

    local apartment = Config.Apartments[aptLabel]
    if not apartment then return end

    local propertyData = {
        owner = citizenid,
        description = string.format("This is %s's apartment in %s",
            PlayerData.firstname .. " " .. PlayerData.lastname, apartment.label),
        for_sale = 0,
        shell = apartment.shell,
        apartment = apartment.label,
    }

    Debug("Creating new apartment for " .. GetPlayerName(src) .. " in " .. apartment.label)

    Framework[Config.Logs].SendLog("Creating new apartment for " .. GetPlayerName(src) .. " in " .. apartment.label)

    RegisterProperty(propertyData)
end)


-- Creates apartment stash
-- If player has an existing apartment from qb-apartments, it will transfer the items over to the new apartment stash
RegisterNetEvent("ps-housing:server:createApartmentStash", function(citizenId, propertyId)
    local stashId = string.format("property_%s", propertyId)

    -- Check for existing apartment and corresponding stash
    local query = 'SELECT items, stash FROM stashitems WHERE stash'
    local result = MySQL.query.await(('%s IN (SELECT name FROM apartments WHERE citizenid = ?)'):format(query),
        { citizenId })
    local items = {}
    if result[1] ~= nil then
        items = json.decode(result[1].items)

        -- Delete the old apartment stash as it is no longer needed
        MySQL.update.await('DELETE FROM stashitems WHERE stash = ?', { result[1].identifier or result[1].stash })
    end

    -- This will create the stash for the apartment (without requiring player to have first opened and placed item in it)
    TriggerEvent('qb-inventory:server:SaveStashItems', stashId, items)
end)

RegisterNetEvent('qb-apartments:returnBucket', function()
    local src = source
    SetPlayerRoutingBucket(src, 0)
end)

AddEventHandler("ps-housing:server:addTenantToApartment", function(data)
    local apartment = data.apartment
    local targetSrc = tonumber(data.targetSrc)
    local realtorSrc = data.realtorSrc
    local targetCitizenid = GetCitizenid(targetSrc, realtorSrc)

    -- id of current apartment so we can change it
    local property_id = nil

    for _, v in pairs(PropertiesTable) do
        local propertyData = v.propertyData
        if propertyData.owner == targetCitizenid then
            if propertyData.apartment == apartment then
                Framework[Config.Notify].Notify(targetSrc, "You are already in this apartment", "error")
                Framework[Config.Notify].Notify(targetSrc, "This person is already in this apartment", "error")

                return
            elseif propertyData.apartment and #propertyData.apartment > 1 then
                property_id = propertyData.property_id
                break
            end
        end
    end

    if property_id == nil then
        local newApartment = Config.Apartments[apartment]
        if not newApartment then return end        
        local targetToAdd = vRP.getPlayerInfo( targetSrc )
        local propertyData = {
            owner = targetCitizenid,
            description = string.format("This is %s's apartment in %s",
                targetToAdd.firstname .. " " .. targetToAdd.lastname, apartment.label),
            for_sale = 0,
            shell = newApartment.shell,
            apartment = newApartment.label,
        }

        Debug("Creating new apartment for " .. GetPlayerName(targetSrc) .. " in " .. newApartment.label)

        Framework[Config.Logs].SendLog("Creating new apartment for " ..
            GetPlayerName(targetSrc) .. " in " .. newApartment.label)

        Framework[Config.Notify].Notify(targetSrc, "Your apartment is now at " .. apartment, "success")
        Framework[Config.Notify].Notify(realtorSrc,
            "You have added " ..
            targetToAdd.charinfo.firstname .. " " .. targetToAdd.charinfo.lastname .. " to apartment " .. apartment,
            "success")

        RegisterProperty(propertyData, true)

        return
    end

    local property = Property.Get(property_id)
    if not property then return end

    property:UpdateApartment(data)
    
    local targetToAdd = vRP.getPlayerInfo( targetSrc )
    if not targetToAdd then return end    

    Frark[Config.Notify].Notify(targetSrc, "Your apartment is now at " .. apartment, "success")
    Framework[Config.Notify].Notify(realtorSrc,
        "You have added " ..
        targetToAdd.firstname .. " " .. targetToAdd.lastname .. " to apartment " .. apartment,
        "success")
end)

exports('IsOwner', function(src, property_id)
    local property = Property.Get(property_id)
    if not property then return false end

    local citizenid = GetCitizenid(src, src)
    return property:CheckForAccess(citizenid)
end)

function GetCitizenid(targetSrc, callerSrc)
    local id = vRP.getCharaterIdBySource(targetSrc)
    if not id then
        Framework[Config.Notify].Notify(callerSrc, locale('player_not_found'), "error")
        return
    end    
    return id
end

function GetCharName(src)
    local xPlayer = vRP.getPlayerInfo(tonumber(src))
    if not xPlayer then return end    
    return xPlayer.firstname .. " " .. xPlayer.lastname
end

function GetPlayerData(src)
    return GetPlayer(src)
end

function GetPlayer(src)
    return vRP.getPlayerInfo(tonumber(src))
end