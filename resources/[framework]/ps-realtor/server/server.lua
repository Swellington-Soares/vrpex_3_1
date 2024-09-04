lib.locale()
local Proxy = require('@vrp.lib.Proxy')
local vRP = Proxy.getInterface('vRP')

RegisterNetEvent("bl-realtor:server:updateProperty", function(type, property_id, data)    
    local src = source
    local user_id = vRP.getUserId( src )
    if not user_id then return false end
    local group = vRP.getUserGroupByType(user_id, 'job')
    if not RealtorJobs[group] then return false end
    data.realtorSrc = src    
    TriggerEvent("ps-housing:server:updateProperty", type, property_id, data)
end)

RegisterNetEvent("bl-realtor:server:registerProperty", function(data)
    local src = source
    local user_id = vRP.getUserId( src )
    if not user_id then return false end
    local group = vRP.getUserGroupByType(user_id, 'job')
    if not RealtorJobs[group] then return false end
    data.realtorSrc = src    
    TriggerEvent("ps-housing:server:registerProperty", data)
end)

RegisterNetEvent("bl-realtor:server:addTenantToApartment", function(data)
    -- Job check
    local src = source
    local user_id = vRP.getUserId( src )
    if not user_id then return false end
    local group = vRP.getUserGroupByType(user_id, 'job')
    if not RealtorJobs[group] then return false end
    data.realtorSrc = src   
    TriggerEvent("ps-housing:server:addTenantToApartment", data)
end)

lib.callback.register("bl-realtor:server:getNames", function (source, data)

    local src = source
    local user_id = vRP.getUserId( src )
    if not user_id then return false end
    local group = vRP.getUserGroupByType(user_id, 'job')
    if not RealtorJobs[group] then return false end

    
    local names = {}
    for i = 1, #data do
        local target = vRP.getPlayerIdentity(user_id) or vRP.getPlayerIdentity(user_id, true)
        if target then
            names[i] = target.firstname .. ' ' .. target.lastname
        else
            names[i] = "Unknown"
        end
    end
    
    return names
end)



-- if Config.UseItem then
--     QBCore.Functions.CreateUseableItem(Config.ItemName, function(source, item)
--         local src = source
--         local Player = QBCore.Functions.GetPlayer(src)
--         if Player.Functions.GetItemByName(item.name) ~= nil then
--             TriggerClientEvent("bl-realtor:client:toggleUI", src)
--         end
--     end)
-- end
