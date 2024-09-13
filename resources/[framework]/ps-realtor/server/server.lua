RegisterNetEvent("bl-realtor:server:updateProperty", function(type, property_id, data)
    -- Job check
    local src = source
    local xPlayer = vRP.getPlayerInfo( src )
    if not xPlayer then return false end
    
    if not RealtorJobs[xPlayer.job.name] then return false end

    data.realtorSrc = src
    -- Update property
    TriggerEvent("ps-housing:server:updateProperty", type, property_id, data)
end)

RegisterNetEvent("bl-realtor:server:registerProperty", function(data)
    local src = source
    local xPlayer = vRP.getPlayerInfo( src )
    if not xPlayer then return false end
    
    if not RealtorJobs[xPlayer.job.name] then return false end

    data.realtorSrc = src
    return exports['ps-housing']:registerProperty(data, nil, src)
end)

RegisterNetEvent("bl-realtor:server:addTenantToApartment", function(data)
    -- Job check
    local src = source
    local xPlayer = vRP.getPlayerInfo( src )
    if not xPlayer then return false end
    if not RealtorJobs[xPlayer.job.name] then return false end

    data.realtorSrc = src
    -- Add tenant
    TriggerEvent("ps-housing:server:addTenantToApartment", data)
end)

lib.callback.register("bl-realtor:server:getNames", function (source, data)
    local src = source
    local xPlayer = vRP.getPlayerInfo( src )
    if not xPlayer then return false end
    if not RealtorJobs[xPlayer.job.name] then return false end
    
    local names = {}
    for i = 1, #data do
        local zsrc = vRP.getSourceByCharacterId(data[ i ])
        local target = zsrc and vRP.getPlayerInfo( zsrc) or vRP.getPlayerInfoOffLine(data[i])
        if target then
            names[#names+1] = target.firstname .. " " .. target.lastname
        else
            names[#names+1] = "Unknown"
        end
    end
    
    return names
end)

-- if Config.UseItem then
--     QBCore.Functions.CreateUseableItem(Config.ItemName, function(source, item)
--         local src = source
--     local xPlayer = vRP.getPlayerInfo( src )
--     if not xPlayer then return false end
--         if Player.Functions.GetItemByName(item.name) ~= nil then
--             TriggerClientEvent("bl-realtor:client:toggleUI", src)
--         end
--     end)
-- end
