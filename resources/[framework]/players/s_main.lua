AddEventHandler('ox_inventory:openedInventory', function(playerId)
    local user_id = vRP.getUserId(playerId)
    local phys = math.floor( vRP.expToLevel( vRP.getExp(user_id, "physical", "strength") ) ) * 5
    exports.ox_inventory:SetMaxWeight(playerId, phys * 1000)
end)


