local dbloaded = false

MySQL.ready(function()
    MySQL.query('SELECT * FROM properties', {}, function(result)
        if not result then return end

        if result?.id then -- If only one result
            result = { result }
        end

        for _, v in pairs(result) do
            local id = tostring(v.property_id)
            local propertyData = {
                property_id = tostring(id),
                owner = v.owner_id,
                street = v.street,
                region = v.region,
                description = v.description,
                has_access = json.decode(v.has_access),
                extra_imgs = json.decode(v.extra_imgs),
                furnitures = json.decode(v.furnitures),
                for_sale = v.for_sale,
                price = v.price,
                shell = v.shell,
                apartment = v.apartment,
                door_data = json.decode(v.door_data),
                garage_data = json.decode(v.garage_data),
            }
            PropertiesTable[id] = Property:new(propertyData)
        end
        lib.print.info('HOUSES LOADED...')
        dbloaded = true
    end)
end)

lib.callback.register("ps-housing:server:requestProperties", function(source)
    while not dbloaded do  Wait(100) end
    return PropertiesTable
end)

AddEventHandler("ps-housing:server:registerProperty", function(propertyData, preventEnter) -- triggered by realtor job
    local propertyData = propertyData

    propertyData.owner = propertyData.owner or nil
    propertyData.has_access = propertyData.has_access or {}
    propertyData.extra_imgs = propertyData.extra_imgs or {}
    propertyData.furnitures = propertyData.furnitures or {}
    propertyData.door_data = propertyData.door_data or {}
    propertyData.garage_data = propertyData.garage_data or {}

    local cols =
    "(owner_id, street, region, description, has_access, extra_imgs, furnitures, for_sale, price, shell, apartment, door_data, garage_data)"
    local vals =
    "(@owner_id, @street, @region, @description, @has_access, @extra_imgs, @furnitures, @for_sale, @price, @shell, @apartment, @door_data, @garage_data)"

    local id = MySQL.insert.await("INSERT INTO properties " .. cols .. " VALUES " .. vals, {
        ["@owner_id"] = propertyData.owner or nil,
        ["@street"] = propertyData.street,
        ["@region"] = propertyData.region,
        ["@description"] = propertyData.description,
        ["@has_access"] = json.encode(propertyData.has_access),
        ["@extra_imgs"] = json.encode(propertyData.extra_imgs),
        ["@furnitures"] = json.encode(propertyData.furnitures),
        ["@for_sale"] = propertyData.for_sale ~= nil and propertyData.for_sale or 1,
        ["@price"] = propertyData.price or 0,
        ["@shell"] = propertyData.shell,
        ["@apartment"] = propertyData.apartment,
        ["@door_data"] = json.encode(propertyData.door_data),
        ["@garage_data"] = json.encode(propertyData.garage_data),
    })
    id = tostring(id)
    propertyData.property_id = id
    PropertiesTable[id] = Property:new(propertyData)

    TriggerClientEvent("ps-housing:client:addProperty", -1, propertyData)

    if propertyData.apartment and not preventEnter then
        local user_id = vRP.getsUserIdByPlayerId(propertyData.owner)
        if not user_id then return false end
        -- local player = QBCore.Functions.GetPlayerByCitizenId(propertyData.owner)

        local src = vRP.getUserSource(user_id)

        local property = Property.Get(id)
        property:PlayerEnter(src)

        Wait(1000)
        Framework[Config.Notify].Notify(src, locale("info.radial_help"), "info")
    end
end)

lib.callback.register("ps-housing:cb:GetOwnedApartment", function(source, cid)
    Debug("ps-housing:cb:GetOwnedApartment", source, cid)
    if cid ~= nil then
        local result = MySQL.query.await(
            'SELECT * FROM properties WHERE owner_id = ? AND apartment IS NOT NULL AND apartment <> ""', { cid })
        if result[1] ~= nil then
            return result[1]
        end
        return nil
    else
        local src = source
        -- local Player = QBCore.Functions.GetPlayer(src)
        local owner = vRP.getPlayerId(vRP.getUserId(src))

        local result = MySQL.query.await(
            'SELECT * FROM properties WHERE owner_id = ? AND apartment IS NOT NULL AND apartment <> ""', { owner })
        if result[1] ~= nil then
            return result[1]
        end
        return nil
    end
end)

AddEventHandler("ps-housing:server:updateProperty", function(type, property_id, data)
    local property = Property.Get(property_id)
    if not property then return end

    property[type](property, data)
end)


AddEventHandler("onResourceStart", function(resourceName) -- Used for when the resource is restarted while in game
    if (GetCurrentResourceName() == resourceName) then
        while not dbloaded do Wait(50) end
        TriggerClientEvent('ps-housing:client:initialiseProperties', -1, PropertiesTable)
    end
end)

RegisterNetEvent("ps-housing:server:createNewApartment", function(aptLabel)
    local src = source
    if not Config.StartingApartment then return end
    local PlayerData = GetPlayerData(src)

    local apartment = Config.Apartments[aptLabel]
    if not apartment or not PlayerData then return end

    lib.print.info("PlayerData", PlayerData)
    local propertyData = {
        owner = PlayerData.char_id,
        description = string.format("This is %s's apartment in %s", PlayerData.firstname .. " " .. PlayerData.lastname,  apartment.label),
        for_sale = 0,
        shell = apartment.shell,
        apartment = apartment.label,
    }

    Debug("Creating new apartment for " .. GetPlayerName(src) .. " in " .. apartment.label)

    Framework[Config.Logs].SendLog("Creating new apartment for " .. GetPlayerName(src) .. " in " .. apartment.label)

    TriggerEvent("ps-housing:server:registerProperty", propertyData)
end)

RegisterNetEvent('qb-apartments:returnBucket', function()
    local src = source
    SetPlayerRoutingBucket(src, 0)
    Player(src).state:set('instance', 0, true)
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

        local citizenid = GetCitizenid(targetSrc, realtorSrc)
        if not citizenid then return end


        local targetToAdd = GetPlayerData(targetSrc) 

        lib.print.info(targetToAdd)


        local propertyData = {
            owner = targetToAdd.char_id,
            description = string.format("This is %s's apartment in %s", targetToAdd.firstname .. " " .. targetToAdd.lastname, newApartment.label),
            for_sale = 0,
            shell = newApartment.shell,
            apartment = newApartment.label,
        }

        Debug("Creating new apartment for " .. GetPlayerName(targetSrc) .. " in " .. newApartment.label)

        Framework[Config.Logs].SendLog("Creating new apartment for " .. GetPlayerName(targetSrc) .. " in " .. newApartment.label)

        Framework[Config.Notify].Notify(targetSrc, "Your apartment is now at " .. apartment, "success")
        Framework[Config.Notify].Notify(realtorSrc, "You have added " .. targetToAdd.firstname .. " " .. targetToAdd.lastname .. " to apartment " .. apartment, "success")

        TriggerEvent("ps-housing:server:registerProperty", propertyData, true)

        return
    end

    local property = Property.Get(property_id)
    if not property then return end

    property:UpdateApartment(data)

    local citizenid = GetCitizenid(targetSrc, realtorSrc)
    if not citizenid then return end
    local targetPlayer = GetPlayerData(targetSrc)
    if not targetPlayer then return end
    Framework[Config.Notify].Notify(targetSrc, "Your apartment is now at " .. apartment, "success")
    Framework[Config.Notify].Notify(realtorSrc,
        "You have added " .. targetPlayer.firstname .. " " .. targetPlayer.lastname .. " to apartment " .. apartment,
        "success")
end)

exports('IsOwner', function(src, property_id)
    local property = Property.Get(property_id)
    if not property then return false end
    local citizenid = GetCitizenid(src, src)
    return property:CheckForAccess(citizenid)
end)
