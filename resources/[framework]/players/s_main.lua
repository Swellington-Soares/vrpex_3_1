require '@vrp.lib.utils'
local Proxy = require '@vrp.lib.Proxy'
local vRP = Proxy.getInterface('vRP')
local r <const> = GetCurrentResourceName()

local inv_hook = {}


--atualiza a capacidade do inventário baseado na força do personagem.
AddEventHandler('ox_inventory:openedInventory', function(playerId)
    local user_id = vRP.getUserId(playerId)
    local phys = math.floor(vRP.expToLevel(vRP.getExp(user_id, "physical", "strength"))) * 5
    exports.ox_inventory:SetMaxWeight(playerId, phys * 1000)
end)

AddEventHandler("onResourceStop", function(resource)
    if resource ~= r then return end
    for _, v in next, inv_hook or {} do
        exports.ox_inventory:removeHooks(v)
    end
end)


-- RegisterCommand('aptt', function (source, args, raw)
--     local user_id = vRP.getUserId( source )
--     vRP.varyExp(user_id, 'physical', 'strength', 150)

--     print(vRP.getExp(user_id, "physical", "strength"), vRP.expToLevel(vRP.getExp(user_id, "physical", "strength")))
-- end)
