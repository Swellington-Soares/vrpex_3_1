Property = {
    property_id = nil,
    propertyData = nil,
    playersInside = nil,   -- src
    playersDoorbell = nil, -- src

    raiding = false,
}
Property.__index = Property

function Property:new(propertyData)
    local self = setmetatable({}, Property)

    self.property_id = tostring(propertyData.property_id)
    self.propertyData = propertyData

    self.playersInside = {}
    self.playersDoorbell = {}

    local stashName = string.format("property_%s", propertyData.property_id)
    local stashConfig = Config.Shells[propertyData.shell].stash

    Framework[Config.Inventory].RegisterInventory(stashName, propertyData.street or propertyData.apartment or stashName,
        stashConfig)

    return self
end

function Property:PlayerEnter(src)
    local _src = tostring(src)
    self.playersInside[_src] = true

    --TODO: CHECK TIME SYNC DISABLE
    -- TriggerClientEvent('qb-weathersync:client:DisableSync', src)
    TriggerClientEvent('ps-housing:client:enterProperty', src, self.property_id)

    if next(self.playersDoorbell) then
        TriggerClientEvent("ps-housing:client:updateDoorbellPool", src, self.property_id, self.playersDoorbell)
        if self.playersDoorbell[_src] then
            self.playersDoorbell[_src] = nil
        end
    end

    local citizenid = GetCitizenid(src)

    if self:CheckForAccess(citizenid) then
        local user_id = vRP.getUserId(src)
        local insideMeta = vRP.getUserMetadata(user_id, 'inside') or {}
        insideMeta.property_id = self.property_id
        vRP.setUserMetadata(user_id, 'inside', insideMeta)
    end

    local bucket = tonumber(self.property_id) -- because the property_id is a string
    SetPlayerRoutingBucket(src, bucket)
    Player(src).state:set('instance', bucket, true)
end

function Property:PlayerLeave(src)
    local _src = tostring(src)
    self.playersInside[_src] = nil

    -- TriggerClientEvent('qb-weathersync:client:EnableSync', src)

    local citizenid = GetCitizenid(src)

    if self:CheckForAccess(citizenid) then
        local user_id = vRP.getUserId(src)
        vRP.setUserMetadata(user_id, 'inside', nil)
    end

    SetPlayerRoutingBucket(src, 0)
    Player(src).state:set('instance', 0, true)
end

function Property:CheckForAccess(citizenid)
    if self.propertyData.owner == citizenid then return true end
    return lib.table.contains(self.propertyData.has_access, citizenid)
end

function Property:AddToDoorbellPoolTemp(src)
    local _src = tostring(src)

    local name = GetCharName(src)

    self.playersDoorbell[_src] = {
        src = src,
        name = name
    }

    for src, _ in pairs(self.playersInside) do
        local targetSrc = tonumber(src)

        Framework[Config.Notify].Notify(targetSrc, "Someone is at the door.", "info")
        TriggerClientEvent("ps-housing:client:updateDoorbellPool", targetSrc, self.property_id, self.playersDoorbell)
    end

    Framework[Config.Notify].Notify(src, "You rang the doorbell. Just wait...", "info")

    SetTimeout(10000, function()
        if self.playersDoorbell[_src] then
            self.playersDoorbell[_src] = nil
            Framework[Config.Notify].Notify(src, "No one answered the door.", "error")
        end

        for src, _ in pairs(self.playersInside) do
            local targetSrc = tonumber(src)

            TriggerClientEvent("ps-housing:client:updateDoorbellPool", targetSrc, self.property_id, self.playersDoorbell)
        end
    end)
end

function Property:RemoveFromDoorbellPool(src)
    local _src = tostring(src)

    if self.playersDoorbell[_src] then
        self.playersDoorbell[_src] = nil
    end

    for src, _ in pairs(self.playersInside) do
        local targetSrc = tonumber(src)

        TriggerClientEvent("ps-housing:client:updateDoorbellPool", targetSrc, self.property_id, self.playersDoorbell)
    end
end

function Property:StartRaid()
    self.raiding = true

    for src, _ in pairs(self.playersInside) do
        local targetSrc = tonumber(src)
        Framework[Config.Notify].Notify(targetSrc, "This Property is being Raided.", "error")
    end

    SetTimeout(Config.RaidTimer * 60000, function()
        self.raiding = false
    end)
end

function Property:UpdateFurnitures(furnitures)
    local newfurnitures = {}

    for i = 1, #furnitures do
        newfurnitures[i] = {
            id = furnitures[i].id,
            label = furnitures[i].label,
            object = furnitures[i].object,
            position = furnitures[i].position,
            rotation = furnitures[i].rotation,
            type = furnitures[i].type
        }
    end

    self.propertyData.furnitures = newfurnitures

    MySQL.update("UPDATE properties SET furnitures = @furnitures WHERE property_id = @property_id", {
        ["@furnitures"] = json.encode(newfurnitures),
        ["@property_id"] = self.property_id
    })

    for src, _ in pairs(self.playersInside) do
        local targetSrc = tonumber(src)
        TriggerClientEvent("ps-housing:client:updateFurniture", targetSrc, self.property_id, furnitures)
    end
end

function Property:UpdateDescription(data)
    local description = data.description
    local realtorSrc = data.realtorSrc

    if self.propertyData.description == description then return end

    self.propertyData.description = description

    MySQL.update("UPDATE properties SET description = @description WHERE property_id = @property_id", {
        ["@description"] = description,
        ["@property_id"] = self.property_id
    })

    TriggerClientEvent("ps-housing:client:updateProperty", -1, "UpdateDescription", self.property_id, description)

    Framework[Config.Logs].SendLog("**Changed Description** of property with id: " ..
        self.property_id .. " by: " .. GetPlayerName(realtorSrc))

    Debug("Changed Description of property with id: " .. self.property_id, "by: " .. GetPlayerName(realtorSrc))
end

function Property:UpdatePrice(data)
    local price = data.price
    local realtorSrc = data.realtorSrc

    if self.propertyData.price == price then return end

    self.propertyData.price = price

    MySQL.update("UPDATE properties SET price = @price WHERE property_id = @property_id", {
        ["@price"] = price,
        ["@property_id"] = self.property_id
    })

    TriggerClientEvent("ps-housing:client:updateProperty", -1, "UpdatePrice", self.property_id, price)

    Framework[Config.Logs].SendLog("**Changed Price** of property with id: " ..
        self.property_id .. " by: " .. GetPlayerName(realtorSrc))

    Debug("Changed Price of property with id: " .. self.property_id, "by: " .. GetPlayerName(realtorSrc))
end

function Property:UpdateForSale(data)
    local forsale = data.forsale
    local realtorSrc = data.realtorSrc

    self.propertyData.for_sale = forsale

    MySQL.update("UPDATE properties SET for_sale = @for_sale WHERE property_id = @property_id", {
        ["@for_sale"] = forsale and 1 or 0,
        ["@property_id"] = self.property_id
    })

    TriggerClientEvent("ps-housing:client:updateProperty", -1, "UpdateForSale", self.property_id, forsale)

    Framework[Config.Logs].SendLog("**Changed For Sale** of property with id: " ..
        self.property_id .. " by: " .. GetPlayerName(realtorSrc))

    Debug("Changed For Sale of property with id: " .. self.property_id, "by: " .. GetPlayerName(realtorSrc))
end

function Property:UpdateShell(data)
    local shell = data.shell
    local realtorSrc = data.realtorSrc

    if self.propertyData.shell == shell then return end

    self.propertyData.shell = shell

    MySQL.update("UPDATE properties SET shell = @shell WHERE property_id = @property_id", {
        ["@shell"] = shell,
        ["@property_id"] = self.property_id
    })

    TriggerClientEvent("ps-housing:client:updateProperty", -1, "UpdateShell", self.property_id, shell)

    Framework[Config.Logs].SendLog("**Changed Shell** of property with id: " ..
        self.property_id .. " by: " .. GetPlayerName(realtorSrc))

    Debug("Changed Shell of property with id: " .. self.property_id, "by: " .. GetPlayerName(realtorSrc))
end

function Property:UpdateOwner(data)
    local targetSrc = tonumber(data.targetSrc)
    local realtorSrc = tonumber(data.realtorSrc)

    local previousOwner = self.propertyData.owner -- char_id of owner

    local targetPlayer = vRP.getPlayerInfo(targetSrc)
    if not targetPlayer then return end
    local bank = targetPlayer.money?.bank or 0
    local citizenid = targetPlayer.char_id

    self:addMloDoorsAccess(citizenid)

    -- if self.propertyData.shell == 'mlo' and DoorResource == 'qb' then
    --     Framework[Config.Notify].Notify(targetSrc, "Go far away and come back for the door to update and open/close.", "error")
    -- end

    if self.propertyData.owner == citizenid then
        Framework[Config.Notify].Notify(targetSrc, "You already own this property", "error")
        Framework[Config.Notify].Notify(realtorSrc, "Client already owns this property", "error")
    end

    local targetAllow = lib.callback.await("ps-housing:cb:confirmPurchase", targetSrc, self.propertyData.price,
        self.propertyData.street, self.propertyData.property_id)

    if targetAllow ~= 'confirm' then
        Framework[Config.Notify].Notify(targetSrc, "You did not confirm the purchase", "info")
        Framework[Config.Notify].Notify(realtorSrc, "Client did not confirm the purchase", "error")
        return
    end

    if bank < self.propertyData.price then
        Framework[Config.Notify].Notify(targetSrc, "You do not have enough money in your bank account", "error")
        Framework[Config.Notify].Notify(realtorSrc, "Client does not have enough money in their bank account", "error")
        return
    end

    vRP.removeBankMoney(targetPlayer.user_id, self.propertyData.price,
        "Bought Property: " .. self.propertyData.street .. " " .. self.property_id)

    local prevUserId = vRP.getUserIdByPlayerId(previousOwner)
    local prevPlayer = vRP.getPlayerInfo(vRP.getUserSource(prevUserId))

    local realtor = vRP.getPlayerInfo(realtorSrc)

    local realtorGradeLevel = realtor?.job?.rank

    local comission = math.floor(self.propertyData.price * (Config.Commissions[realtorGradeLevel] or 0.05))

    local totalAfterCommission = self.propertyData.price - comission

    if prevPlayer then
        Framework[Config.Notify].Notify(prevPlayer.source,
            "Sold Property: " .. self.propertyData.street .. " " .. self.property_id, "success")
        vRP.giveBankMoney(prevPlayer.user_id, totalAfterCommission,
            "Sold Property: " .. self.propertyData.street .. " " .. self.property_id, true)
    elseif previousOwner then
        local xChar = vRP.getCharacter(previousOwner, false)
        if xChar then
            xChar.money.bank = xChar.money.bank + totalAfterCommission
            vRP.updateCharacter(xChar.id, { money = xChar.money })
        end
    end

    vRP.giveBankMoney(realtor.user_id, totalAfterCommission,
        "Commission from Property: " .. self.propertyData.street .. " " .. self.property_id, true)

    self.propertyData.owner = citizenid

    MySQL.update.await('UPDATE properties SET owner_citizenid = ?, for_sale = 0 WHERE property_id = ?',
        {
            citizenid,
            self.property_id
        })

    self.propertyData.furnitures = {}

    TriggerClientEvent("ps-housing:client:updateProperty", -1, "UpdateOwner", self.property_id, citizenid)
    TriggerClientEvent("ps-housing:client:updateProperty", -1, "UpdateForSale", self.property_id, 0)

    Framework[Config.Logs].SendLog("**House Bought** by: **" ..
        PlayerData.charinfo.firstname ..
        " " ..
        PlayerData.charinfo.lastname ..
        "** for $" ..
        self.propertyData.price ..
        " from **" .. realtor.PlayerData.charinfo.firstname .. " " .. realtor.PlayerData.charinfo.lastname .. "** !")

    Framework[Config.Notify].Notify(targetSrc, "You have bought the property for $" .. self.propertyData.price, "success")
    Framework[Config.Notify].Notify(realtorSrc, "Client has bought the property for $" .. self.propertyData.price,
        "success")
end

function Property:UpdateImgs(data)
    local imgs = data.imgs
    local realtorSrc = data.realtorSrc

    self.propertyData.imgs = imgs

    MySQL.update.await("UPDATE properties SET extra_imgs = ? WHERE property_id = ?", {
        json.encode(imgs),
        self.property_id
    })

    TriggerClientEvent("ps-housing:client:updateProperty", -1, "UpdateImgs", self.property_id, imgs)

    Framework[Config.Logs].SendLog("**Changed Images** of property with id: " ..
        self.property_id .. " by: " .. GetPlayerName(realtorSrc))

    Debug("Changed Imgs of property with id: " .. self.property_id, "by: " .. GetPlayerName(realtorSrc))
end

function Property:UpdateDoor(data)
    local door = data.door

    if not door then return end
    local realtorSrc = data.realtorSrc

    local newDoor = {
        x = math.floor(door.x * 10000) / 10000,
        y = math.floor(door.y * 10000) / 10000,
        z = math.floor(door.z * 10000) / 10000,
        h = math.floor(door.h * 10000) / 10000,
        length = door.length or 1.5,
        width = door.width or 2.2,
        locked = door.locked or false,
    }

    self.propertyData.door_data = newDoor

    self.propertyData.street = data.street
    self.propertyData.region = data.region


    MySQL.update.await(
        "UPDATE properties SET door_data = ?, street = ?, region = ? WHERE property_id = ?", {
            json.encode(newDoor),
            self.property_id,
            data.street,
            data.region
        })

    TriggerClientEvent("ps-housing:client:updateProperty", -1, "UpdateDoor", self.property_id, newDoor, data.street,
        data.region)

    Framework[Config.Logs].SendLog("**Changed Door** of property with id: " ..
        self.property_id .. " by: " .. GetPlayerName(realtorSrc))

    Debug("Changed Door of property with id: " .. self.property_id, "by: " .. GetPlayerName(realtorSrc))
end

function Property:UpdateHas_access(data)
    local has_access = data or {}

    self.propertyData.has_access = has_access

    MySQL.update.await("UPDATE properties SET has_access = ? WHERE property_id = ?", {
        json.encode(has_access), --Array of cids
        self.property_id
    })

    TriggerClientEvent("ps-housing:client:updateProperty", -1, "UpdateHas_access", self.property_id, has_access)

    Debug("Changed Has Access of property with id: " .. self.property_id)
end

function Property:UpdateGarage(data)
    local garage = data.garage
    local realtorSrc = data.realtorSrc

    local newData = {}

    if data ~= nil then
        newData = {
            x = math.floor(garage.x * 10000) / 10000,
            y = math.floor(garage.y * 10000) / 10000,
            z = math.floor(garage.z * 10000) / 10000,
            h = math.floor(garage.h * 10000) / 10000,
            length = garage.length or 3.0,
            width = garage.width or 5.0,
        }
    end

    self.propertyData.garage_data = newData

    MySQL.update.await("UPDATE properties SET garage_data = ? WHERE property_id = ?", {
        json.encode(newData),
        self.property_id
    })

    TriggerClientEvent("ps-housing:client:updateProperty", -1, "UpdateGarage", self.property_id, newData)

    Framework[Config.Logs].SendLog("**Changed Garage** of property with id: " ..
        self.property_id .. " by: " .. GetPlayerName(realtorSrc))

    Debug("Changed Garage of property with id: " .. self.property_id, "by: " .. GetPlayerName(realtorSrc))
end

function Property:UpdateApartment(data)
    local apartment = data.apartment
    local realtorSrc = data.realtorSrc
    local targetSrc = data.targetSrc

    self.propertyData.apartment = apartment

    MySQL.update.await("UPDATE properties SET apartment = ? WHERE property_id = ?", {
        apartment,
        self.property_id
    })

    Framework[Config.Notify].Notify(realtorSrc,
        "Changed Apartment of property with id: " .. self.property_id .. " to " .. apartment, "success")

    Framework[Config.Notify].Notify(targetSrc, "Changed Apartment to " .. apartment, "success")

    Framework[Config.Logs].SendLog("**Changed Apartment** with id: " ..
        self.property_id .. " by: **" .. GetPlayerName(realtorSrc) .. "** for **" .. GetPlayerName(targetSrc) .. "**")

    TriggerClientEvent("ps-housing:client:updateProperty", -1, "UpdateApartment", self.property_id, apartment)

    Debug("Changed Apartment of property with id: " .. self.property_id, "by: " .. GetPlayerName(realtorSrc))
end

function Property:DeleteProperty(data)
    local realtorSrc = data.realtorSrc
    local propertyid = self.property_id
    local realtorName = GetPlayerName(realtorSrc)

    MySQL.update("DELETE FROM properties WHERE property_id = ?", { propertyid }, function(rowsChanged)
        if rowsChanged > 0 then
            Debug("Deleted property with id: " .. propertyid, "by: " .. realtorName)
        end
    end)

    TriggerClientEvent("ps-housing:client:removeProperty", -1, propertyid)

    Framework[Config.Notify].Notify(realtorSrc, "Property with id: " .. propertyid .. " has been removed.", "info")

    Framework[Config.Logs].SendLog("**Property Deleted** with id: " .. propertyid .. " by: " .. realtorName)

    PropertiesTable[propertyid] = nil
    self = nil

    Debug("Deleted property with id: " .. propertyid, "by: " .. realtorName)
end

function Property.Get(property_id)
    return PropertiesTable[tostring(property_id)]
end

RegisterNetEvent('ps-housing:server:enterProperty', function(property_id)
    local src = source
    Debug("Player is trying to enter property", property_id)

    local property = Property.Get(property_id)

    if not property then
        Debug("Properties returned", json.encode(PropertiesTable, { indent = true }))
        return
    end

    local citizenid = GetCitizenid(src)

    if property:CheckForAccess(citizenid) then
        Debug("Player has access to property")
        property:PlayerEnter(src)
        Debug("Player entered property")
        return
    end

    local ringDoorbellConfirmation = lib.callback.await('ps-housing:cb:ringDoorbell', src)
    if ringDoorbellConfirmation == "confirm" then
        property:AddToDoorbellPoolTemp(src)
        Debug("Ringing doorbell")
        return
    end
end)

RegisterNetEvent("ps-housing:server:showcaseProperty", function(property_id)
    local src = source

    local property = Property.Get(property_id)

    if not property then
        Debug("Properties returned", json.encode(PropertiesTable, { indent = true }))
        return
    end


    local PlayerData = GetPlayerData(src)
    local job = PlayerData.job
    local jobName = job.name
    local onDuty = job.onduty

    if job and jobRealtorJobs[jobName] and onDuty then
        local showcase = lib.callback.await('ps-housing:cb:showcase', src)
        if showcase == "confirm" then
            property:PlayerEnter(src)
            return
        end
    end
end)

RegisterNetEvent('ps-housing:server:raidProperty', function(property_id)
    local src = source
    Debug("Player is trying to raid property", property_id)

    local property = Property.Get(property_id)

    if not property then
        Debug("Properties returned", json.encode(PropertiesTable, { indent = true }))
        return
    end

    local xPlayer = vRP.getPlayerInfo(src)
    if not xPlayer then return end
    local job = xPlayer.job
    local jobName = job.name
    local gradeAllowed = job.rank >= Config.MinGradeToRaid
    local onDuty = job.onduty or job.duty
    local raidItem = Config.RaidItem

    local hasStormRam = exports.ox_inventory:Search(src, 'count', raidItem) > 0
    local isAllowedToRaid = jobName ~= '' and PoliceJobs[jobName] and onDuty and gradeAllowed
    if isAllowedToRaid then
        if hasStormRam then
            if not property.raiding then
                local confirmRaid = lib.callback.await('ps-housing:cb:confirmRaid', src,
                    (property.propertyData.street or property.propertyData.apartment) .. " " .. property.property_id,
                    property_id)
                if confirmRaid == "confirm" then
                    property:StartRaid(src)
                    property:PlayerEnter(src)
                    Framework[Config.Notify].Notify(src, "Raid started", "success")
                    if Config.ConsumeRaidItem then
                        exports.ox_inventory:RemoveItem(src, raidItem, 1)
                    end
                end
            else
                Framework[Config.Notify].Notify(src, "Raid in progress", "success")
                property:PlayerEnter(src)
            end
        else
            Framework[Config.Notify].Notify(src, "You need a stormram to perform a raid", "error")
        end
    else
        if not PoliceJobs[jobName] then
            Framework[Config.Notify].Notify(src, "Only police officers are permitted to perform raids", "error")
        elseif not onDuty then
            Framework[Config.Notify].Notify(src, "You must be onduty before performing a raid", "error")
        elseif not gradeAllowed then
            Framework[Config.Notify].Notify(src, "You must be a higher rank before performing a raid", "error")
        end
    end
end)



lib.callback.register('ps-housing:cb:getFurnitures', function(source, property_id)
    local property = Property.Get(property_id)
    if not property then return end
    return property.propertyData.furnitures or {}
end)


lib.callback.register('ps-housing:cb:getPlayersInProperty', function(source, property_id)
    local property = Property.Get(property_id)
    if not property then return end

    local players = {}

    for src, _ in pairs(property.playersInside) do
        local targetSrc = tonumber(src)
        if targetSrc ~= source then
            local name = GetCharName(targetSrc)

            players[#players + 1] = {
                src = targetSrc,
                name = name
            }
        end
    end

    return players or {}
end)

RegisterNetEvent('ps-housing:server:leaveProperty', function(property_id)
    local src = source
    local property = Property.Get(property_id)

    if not property then return end

    property:PlayerLeave(src)
end)

-- When player presses doorbell, owner can let them in and this is what is triggered
RegisterNetEvent("ps-housing:server:doorbellAnswer", function(data)
    local src = source
    local targetSrc = data.targetSrc

    local property = Property.Get(data.property_id)
    if not property then return end

    if not property.playersInside[tostring(src)] then return end
    property:RemoveFromDoorbellPool(targetSrc)

    property:PlayerEnter(targetSrc)
end)

--@@ NEED TO REDO THIS DOG SHIT
-- I think its not bad anymore but if u got a better idea lmk
RegisterNetEvent("ps-housing:server:buyFurniture", function(property_id, items, price)
    local src = source

    local xPlayer = vRP.getPlayerInfo(src)
    local citizenid = xPlayer.char_id

    local property = Property.Get(property_id)
    if not property then return end
    if not property:CheckForAccess(citizenid) then return end

    local price = tonumber(price)

    if not vRP.tryFullPayment(xPlayer.user_id, price) then
        Framework[Config.Notify].Notify(src, "You do not have enough money!", "error")
        return
    end

    local numFurnitures = #property.propertyData.furnitures

    for i = 1, #items do
        numFurnitures = numFurnitures + 1
        property.propertyData.furnitures[numFurnitures] = items[i]
    end

    property:UpdateFurnitures(property.propertyData.furnitures)

    Framework[Config.Notify].Notify(src, "You bought furniture for $" .. price, "success")

    Framework[Config.Logs].SendLog("**Player " .. GetPlayerName(src) .. "** bought furniture for **$" .. price .. "**")

    Debug("Player bought furniture for $" .. price, "by: " .. GetPlayerName(src))
end)

RegisterNetEvent("ps-housing:server:removeFurniture", function(property_id, itemid)
    local src = source

    local property = Property.Get(property_id)
    if not property then return end

    local citizenid = GetCitizenid(src)
    if not property:CheckForAccess(citizenid) then return end

    local currentFurnitures = property.propertyData.furnitures

    for k, v in pairs(currentFurnitures) do
        if v.id == itemid then
            table.remove(currentFurnitures, k)
            break
        end
    end

    property:UpdateFurnitures(currentFurnitures)
end)

-- @@ VERY BAD
-- I think its not bad anymore but if u got a better idea lmk
RegisterNetEvent("ps-housing:server:updateFurniture", function(property_id, item)
    local src = source

    local property = Property.Get(property_id)
    if not property then return end

    local citizenid = GetCitizenid(src)
    if not property:CheckForAccess(citizenid) then return end

    local currentFurnitures = property.propertyData.furnitures

    for k, v in pairs(currentFurnitures) do
        if v.id == item.id then
            currentFurnitures[k] = item
            Debug("Updated furniture", json.encode(item))
            break
        end
    end

    property:UpdateFurnitures(currentFurnitures)
end)

RegisterNetEvent("ps-housing:server:addAccess", function(property_id, srcToAdd)
    local src = source

    local citizenid = GetCitizenid(src)
    local property = Property.Get(property_id)
    if not property then return end

    if not property.propertyData.owner == citizenid then
        -- hacker ban or something
        Framework[Config.Notify].Notify(src, "You are not the owner of this property!", "error")
        return
    end

    local has_access = property.propertyData.has_access

    local targetCitizenid = GetCitizenid(srcToAdd)
    local targetPlayer = GetPlayerData(srcToAdd)

    if not property:CheckForAccess(targetCitizenid) then
        has_access[#has_access + 1] = targetCitizenid
        property:UpdateHas_access(has_access)

        Framework[Config.Notify].Notify(src,
            "You added access to " .. targetPlayer.firstname .. " " .. targetPlayer.lastname, "success")
        Framework[Config.Notify].Notify(srcToAdd, "You got access to this property!", "success")
    else
        Framework[Config.Notify].Notify(src, "This person already has access to this property!", "error")
    end
end)

RegisterNetEvent("ps-housing:server:removeAccess", function(property_id, citizenidToRemove)
    local src = source

    local citizenid = GetCitizenid(src)
    local property = Property.Get(property_id)
    if not property then return end

    if not property.propertyData.owner == citizenid then
        -- hacker ban or something
        Framework[Config.Notify].Notify(src, "You are not the owner of this property!", "error")
        return
    end

    local has_access = property.propertyData.has_access
    local citizenidToRemove = citizenidToRemove

    if property:CheckForAccess(citizenidToRemove) then
        for i = 1, #has_access do
            if has_access[i] == citizenidToRemove then
                table.remove(has_access, i)
                break
            end
        end

        property:UpdateHas_access(has_access)

        local playerToAdd = vRP.getCharacter(citizenidToRemove)

        if playerToAdd then
            local srcToRemove = vRP.getUserSource(playerToAdd.user_id)
            if srcToRemove then
                Framework[Config.Notify].Notify(srcToRemove,
                    "You lost access to " ..
                    (property.propertyData.street or property.propertyData.apartment) .. " " .. property.property_id,
                    "error")
            end

            Framework[Config.Notify].Notify(src,
                "You removed access from " ..
                playerToAdd.firstname .. " " .. playerToAdd.lastname, "success")
        else
            Framework[Config.Notify].Notify(src, "You removed access from " .. citizenidToRemove, "success")
        end
    else
        Framework[Config.Notify].Notify(src, "This person does not have access to this property!", "error")
    end
end)

lib.callback.register("ps-housing:cb:getPlayersWithAccess", function(source, property_id)
    local src = source
    local citizenidSrc = GetCitizenid(src)
    local property = Property.Get(property_id)

    if not property then return end
    if property.propertyData.owner ~= citizenidSrc then return end

    local withAccess = {}
    local has_access = property.propertyData.has_access

    for i = 1, #has_access do
        local citizenid = has_access[i]
        local xPlayer = vRP.getCharacter(citizenid)
        if xPlayer then
            withAccess[#withAccess + 1] = {
                citizenid = citizenid,
                name = xPlayer.firstname .. " " .. xPlayer.lastname
            }
        end
    end

    return withAccess
end)

lib.callback.register('ps-housing:cb:getPropertyInfo', function(source, property_id)
    local src = source
    local property = Property.Get(property_id)

    if not property then return end

    local xPlayer = vRP.getPlayerInfo(src)
    local job = xPlayer.job
    local jobName = job.name
    local onDuty = job.onduty or job.duty

    if job ~= '' and RealtorJobs[jobName] and not onDuty then return end

    local data = {}

    local ownerPlayer, ownerName

    local ownerCid = property.propertyData.owner
    if ownerCid then
        if ownerCid == xPlayer.char_id then
            ownerName = xPlayer.firstname .. " " .. xPlayer.lastname
        else
            ownerPlayer = vRP.getCharacter(ownerCid)
            if ownerPlayer then
                ownerName = ownerPlayer.firstname .. " " .. ownerPlayer.lastname
            end
        end
    else
        ownerName = "No Owner"
    end

    data.owner = ownerName
    data.street = property.propertyData.street
    data.region = property.propertyData.region
    data.description = property.propertyData.description
    data.for_sale = property.propertyData.for_sale
    data.price = property.propertyData.price
    data.shell = property.propertyData.shell
    data.property_id = property.property_id

    return data
end)

RegisterNetEvent('ps-housing:server:resetMetaData', function()
    local src = source
    local user_id = vRP.getUserId(src)
    if not user_id then return end
    vRP.setUserMetadata(user_id, 'inside', { property_id = nil})    
end)
