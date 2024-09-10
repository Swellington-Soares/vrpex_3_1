lib.locale()
local Proxy = require('@vrp.lib.Proxy')
vRP = Proxy.getInterface('vRP')

PropertiesTable = {}
ApartmentsTable = {}

exports('GetProperties', function() return PropertiesTable end)
exports('GetApartments', function() return ApartmentsTable end)

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
    Framework.qb = {}
    Framework.vrpex = {}

    function Framework.ox.Notify(src, message, type)
        type = type == "inform" and "info" or type
        TriggerClientEvent("ox_lib:notify", src, {title="Property", description=message, type=type})
    end

    function Framework.ox.RegisterInventory(stash, label, stashConfig)
        exports.ox_inventory:RegisterStash(stash, label, stashConfig.slots, stashConfig.maxweight, nil)
    end

    function Framework.vrpex.SendLog(message)
        exports['vrp']:CreateLog( 'pshousing', 'Housing System', message )
    end

    function GetPlayerData(src)
        return vRP.getPlayerInfo(src) --vRP.getUserIdentity( vRP.getUserId( src ) )
    end
    
    
    function GetCitizenid(targetSrc, callerSrc)
        local char_id = vRP.getPlayerId( vRP.getUserId( targetSrc ) )
        if not char_id and callerSrc then
            Framework[Config.Notify].Notify(callerSrc, "Player not found.", "error")
            return false
        end
        
        return char_id    
    end
    
    function GetCharName(src)
       local data = GetPlayerData(src)
       if not data then return "" end
       return data.firstname .. " " ..  data.lastname
    end
    
    
    function GetPlayer(src)
        return vRP.getPlayerTable(vRP.getUserId(src))
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
                    label = locale("target.enter_prop"),
                    icon = "fas fa-door-open",
                    onSelect = enter,
                    canInteract = function()
                        local property = Property.Get(property_id)                    
                        return property.has_access or property.owner
                    end,
                },
                {
                    label = locale("target.show_prop"),
                    icon = "fas fa-eye",
                    onSelect = showcase,
                    canInteract = function()
                        local property = Property.Get(property_id)
                        if property.propertyData.owner ~= nil then return false end -- if its owned, it cannot be showcased                                                                        
                        return PlayerData?.job?.name and  RealtorJobs[PlayerData.job.name] or false                        
                    end,
                },
                {
                    label = locale("target.prop_info"),
                    icon = "fas fa-circle-info",
                    onSelect = showData,
                    canInteract = function()
                        local job = PlayerData?.job
                        if job then
                            local jobName = job.name
                            local onDuty = job.onduty
                            return jobName and RealtorJobs[jobName] and onDuty
                        end
                        return false
                    end,
                },
                {
                    label = locale("target.ring_door"),
                    icon = "fas fa-bell",
                    onSelect = enter,
                    canInteract = function()
                        local property = Property.Get(property_id)                        
                        return not property.has_access and not property.owner
                    end,
                },
                {
                    label = locale("target.raid_prop"),
                    icon = "fas fa-building-shield",
                    onSelect = raid,
                    canInteract = function()
                        local job = PlayerData?.job
                        if job then
                            local jobName = job.name
                            local gradeAllowed = tonumber(job.rank) >= Config.MinGradeToRaid
                            local onDuty = job.onduty
                            return PoliceJobs[jobName] and onDuty and gradeAllowed
                        end                        
                        return false
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
                    label = locale("target.enter_apt"),
                    onSelect = enter,
                    icon = "fas fa-door-open",
                    canInteract = function()
                        local apartments = ApartmentsTable[apartment].apartments
                        return hasApartment(apartments)
                    end,
                },
                {
                    label = locale("target.see_apt"),
                    onSelect = seeAll,
                    icon = "fas fa-circle-info",
                },
                {
                    label =  locale("target.raid_apt"),
                    onSelect = seeAllToRaid,
                    icon = "fas fa-building-shield",
                    canInteract = function()
                        local job = PlayerData?.job
                        if job then
                            local jobName = job.name
                            local gradeAllowed = tonumber(job.rank) >= Config.MinGradeToRaid
                            local onDuty = job.onduty
                            return PoliceJobs[jobName] and onDuty and gradeAllowed
                        end
                        return false
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
                    label =  locale("target.leave"),
                    onSelect = leave,
                    icon = "fas fa-right-from-bracket",
                },
                {
                    name = "doorbell",
                    label = locale("target.doorbell"),
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
                    label = locale("target.leave"),
                    onSelect = leave,
                    icon = "fas fa-right-from-bracket",
                },
            },
        })        
        return handler
    end,

    RemoveTargetZone = function (handler)
        exports.ox_target:removeZone(handler, false)
        
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

    RemoveTargetEntity = function (entity)
        exports.ox_target:removeLocalEntity(entity)
    end,

    OpenInventory = function (stash, stashConfig)
        exports.ox_inventory:openInventory('stash', stash)
    end,
}
