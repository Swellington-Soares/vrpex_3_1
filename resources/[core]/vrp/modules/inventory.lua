function vRP.getItemDefinition(idname)

end

function vRP.getItemName(idname)

end

function vRP.getItemDescription(idname)
end

function vRP.getItemWeight(idname)
end

function vRP.computeItemsWeight(items)

end

function vRP.giveInventoryItem(user_id, idname, amount, notify)

end

-- try to get item from a connected user inventory
function vRP.tryGetInventoryItem(user_id, idname, amount, notify)

end

-- get item amount from a connected user inventory
function vRP.getInventoryItemAmount(user_id, idname)
 
end


function vRP.getInventory(user_id)
 
end

-- return user inventory total weight
function vRP.getInventoryWeight(user_id)

end

-- return maximum weight of the user inventory
function vRP.getInventoryMaxWeight(user_id)
--  return math.floor(vRP.expToLevel(vRP.getExp(user_id, "physical", "strength"))) * cfg.inventory_weight_per_strength
end

-- clear connected user inventory
function vRP.clearInventory(user_id)
  
end
