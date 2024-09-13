Framework = {}

PoliceJobs = {}
RealtorJobs = {}

-- Convert config table to usable keys
for i = 1, #Config.PoliceJobNames do
    PoliceJobs[Config.PoliceJobNames[i]] = true
end

for i = 1, #Config.RealtorJobNames do
    RealtorJobs[Config.RealtorJobNames[i]] = true
end

if IsDuplicityVersion() then
    Framework.ox = {}

    function Framework.ox.Notify(src, message, type)
        type = type == "inform" and "info" or type
        TriggerClientEvent("ox_lib:notify", src, {title="Property", description=message, type=type})
    end


    function Framework.ox.RegisterInventory(stash, label, stashConfig)
        exports.ox_inventory:RegisterStash(stash, label, stashConfig.slots, stashConfig.maxweight, nil)
    end
        
    function Framework.ox.SendLog(message)
        lib.print.info(message)
    end

    return
end

local function hasApartment(apts)
    for propertyId, _  in pairs(apts) do
        local property = PropertiesTable[propertyId]
        if property.owner then
            return true
        end
    end

    return false
end

Framework.ox = {
    Notify = function(message, type)
        type = type == "inform" and "info" or type
        
        lib.notify({
            title = 'Property',
            description = message,
            type = type
        })
    end,

    AddEntrance = function (coords, size, heading, propertyId, enter, raid, showcase, showData, _)
        local property_id = propertyId

        local handler = exports.ox_target:addBoxZone({
            coords = vector3(coords.x, coords.y, coords.z),
            size = vector3(size.y, size.x, size.z),
            rotation = heading,
            debug = Config.DebugMode,
            options = {
                {
                    label = "Enter Property",
                    icon = "fas fa-door-open",
                    onSelect = enter,
                    canInteract = function()
                        local property = Property.Get(property_id)
                        return property.has_access or property.owner
                    end,
                },
                {
                    label = "Showcase Property",
                    icon = "fas fa-eye",
                    onSelect = showcase,
                    canInteract = function()
                        -- local property = Property.Get(property_id)
                        -- if property.propertyData.owner ~= nil then return false end -- if its owned, it cannot be showcased
                        
                        local job = PlayerData.job
                        local jobName = job.name

                        return RealtorJobs[jobName]
                    end,
                },
                {
                    label = "Property Info",
                    icon = "fas fa-circle-info",
                    onSelect = showData,
                    canInteract = function()
                        local job = PlayerData.job
                        local jobName = job.name
                        local onDuty = job.onduty
                        return RealtorJobs[jobName] and onDuty
                    end,
                },
                {
                    label = "Ring Doorbell",
                    icon = "fas fa-bell",
                    onSelect = enter,
                    canInteract = function()
                        local property = Property.Get(property_id)
                        return not property.has_access and not property.owner
                    end,
                },
                {
                    label = "Raid Property",
                    icon = "fas fa-building-shield",
                    onSelect = raid,
                    canInteract = function()
                        local job = PlayerData.job
                        local jobName = job.name
                        local gradeAllowed = tonumber(job.grade.level) >= Config.MinGradeToRaid
                        local onDuty = job.onduty

                        return PoliceJobs[jobName] and onDuty and gradeAllowed
                    end,
                },
            },
        })

        return handler
    end,

    AddApartmentEntrance = function (coords, size, heading, apartment, enter, seeAll, seeAllToRaid, _)        
        local handler = exports.ox_target:addBoxZone({
            coords = vector3(coords.x, coords.y, coords.z),
            size = vector3(size.y, size.x, size.z),
            rotation = heading,
            debug = Config.DebugMode,
            options = {
                {
                    label = "Enter Apartment",
                    onSelect = enter,
                    icon = "fas fa-door-open",
                    canInteract = function()
                        local apartments = ApartmentsTable[apartment].apartments
                        return hasApartment(apartments)
                    end,
                },
                {
                    label = "See all apartments",
                    onSelect = seeAll,
                    icon = "fas fa-circle-info",
                },
                {
                    label = "Raid Apartment",
                    onSelect = seeAllToRaid,
                    icon = "fas fa-building-shield",
                    canInteract = function()
                        local job = PlayerData.job
                        local jobName = job.name
                        local gradeAllowed = tonumber(job.grade.level) >= Config.MinGradeToRaid
                        local onDuty = job.onduty

                        return PoliceJobs[jobName] and onDuty and gradeAllowed
                    end,
                },
            },
        })

        return handler
    end,

    AddDoorZoneInside = function (coords, size, heading, leave, checkDoor)
        local handler = exports.ox_target:addBoxZone({
            coords = vector3(coords.x, coords.y, coords.z), --z = 3.0
            size = vector3(size.y, size.x, size.z),
            rotation = heading,
            debug = Config.DebugMode,
            options = {
                {
                    name = "leave",
                    label = "Leave Property",
                    onSelect = leave,
                    icon = "fas fa-right-from-bracket",
                },
                {
                    name = "doorbell",
                    label = "Check Door",
                    onSelect = checkDoor,
                    icon = "fas fa-bell",
                },
            },
        })

        return handler
    end,

    AddDoorZoneInsideTempShell = function (coords, size, heading, leave)
        local handler = exports.ox_target:addBoxZone({
            coords = vector3(coords.x, coords.y, coords.z), --z = 3.0
            size = vector3(size.y, size.x, size.z),
            rotation = heading,
            debug = Config.DebugMode,
            options = {
                {
                    name = "leave",
                    label = "Leave",
                    onSelect = leave,
                    icon = "fas fa-right-from-bracket",
                },
            },
        })
        print("made")
        return handler
    end,

    RemoveTargetZone = function (handler)
        exports.ox_target:removeZone(handler)
    end,

    AddRadialOption = function(id, label, icon, fn)
        lib.addRadialItem({
            id = id,
            icon = icon,
            label = label,
            onSelect = fn,
        })
    end,

    RemoveRadialOption = function(id)
        lib.removeRadialItem(id)
    end,

    AddTargetEntity = function (entity, label, icon, action)
        exports.ox_target:addLocalEntity(entity, {
            {
                name = label,
                label = label,
                icon = icon,
                onSelect = action,
            },
        })
    end,
    inventoryHasItems = function(name)
        return lib.callback.await('ps-housing:cb:inventoryHasItems', 10, name, true)
    end,
    RemoveTargetEntity = function (entity)
        exports.ox_target:removeLocalEntity(entity)
    end,

    OpenInventory = function (stash, stashConfig)
        exports.ox_inventory:openInventory('stash', stash)
    end,
}
