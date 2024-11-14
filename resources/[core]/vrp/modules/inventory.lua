local usable_items = {}


function vRP.createUseableItem(item, cb)
    if (type(item) ~= "string") or not cb then return end
    usable_items[item] = cb
end

function vRP.canUseItem(item)
    return usable_items[item]
end

exports('CreateUseableItem', vRP.createUseableItem)
exports('GetUsableItem', vRP.canUseItem)

function vRP.getItemName(idname)
    return exports.ox_inventory:Items(idname)?.label
end

function vRP.getItemDescription(idname)
    return exports.ox_inventory:Items(idname)?.description
end

function vRP.getItemWeight(idname)
    return exports.ox_inventory:Items(idname)?.weight
end

function vRP.computeItemsWeight(items)
    if type(items) ~= "table" then return 0 end
    local sum = 0
    for _, itemname in next, items or {} do
        sum = sum + vRP.getItemWeight(itemname)
    end
    return sum
end

function vRP.giveInventoryItem(user_id, idname, amount, meta)
    local source = vRP.getUserSource(user_id)
    if not source then return false end
    return exports.ox_inventory:AddItem(source, idname, amount, meta)
end

-- try to get item from a connected user inventory
function vRP.tryGetInventoryItem(user_id, idname, amount, notify)
    local source = vRP.getUserSource(user_id)
    if not source then return false end
    return exports.ox_inventory:RemoveItem(source, idname, amount)
end

-- get item amount from a connected user inventory
function vRP.getInventoryItemAmount(user_id, idname)
    local source = vRP.getUserSource(user_id)
    if not source then return false end
    return exports.ox_inventory:Search(source, 'count', idname)
end

function vRP.getInventory(user_id)
    local source = vRP.getUserSource(user_id)
    if not source then return false end
    return exports.ox_inventory:GetInventoryItems(source)
end

-- return user inventory total weight
function vRP.getInventoryWeight(user_id)
    local source = vRP.getUserSource(user_id)
    if not source then return false end
    return exports.ox_inventory:GetInventory(source)?.weight or 0
end

-- return maximum weight of the user inventory
function vRP.getInventoryMaxWeight(user_id)
    local source = vRP.getUserSource(user_id)
    if not source then return false end
    return exports.ox_inventory:GetInventory(source)?.maxWeight or 0
end

-- clear connected user inventory
function vRP.clearInventory(user_id)
    local source = vRP.getUserSource(user_id)
    if not source then return false end
    exports.ox_inventory:ClearInventory(source, {
        'id_card',
        'driver_license',
        'weapon_license'
    })
end
