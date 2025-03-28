local Weapon = require 'modules.weapon.client'

AddStateBagChangeHandler('isLoggedIn', ('player:%s'):format(cache.serverId), function(_, _, value)
    PlayerData.loaded = value
    if not value then
        return client.onLogout()
    end    
end)

AddStateBagChangeHandler('handcuffed', ('player:%s'):format(cache.serverId), function(_, _, value)
    LocalPlayer.state:set('invBusy', value, false)
    PlayerData.cuffed = value
    if not value then return end
    Weapon.Disarm()
end)


RegisterNetEvent('vRP:updateGroupInfo', function(group)
    local groups = PlayerData?.groups or {}
    if group.action == 'leave' or not group?.rank or group.rank == 0 then
        if groups[group.name] then
            groups[group.name] = nil
        end
    elseif group.action == 'enter' and group?.rank and group?.rank > 0 then
        groups[group.name] = group.rank
    end
    client.setPlayerData('groups', groups)
end)

---@diagnostic disable-next-line: duplicate-set-field
function client.setPlayerStatus(values)
    lib.print.info('setPlayerStatus', values)
    -- for name, value in pairs(values) do
    --     -- Thanks to having status values setup out of 1000000 (matching esx_status's standard)
    --     -- we need to awkwardly change the value
    --     if value > 100 or value < -100 then
    --         -- Hunger and thirst start at 0 and go up to 100 as you get hungry/thirsty (inverse of ESX)
    --         if (name == 'hunger' or name == 'thirst') then
    --             value = -value
    --         end

    --         value = value * 0.0001
    --     end

    --     ---@diagnostic disable-next-line: undefined-global
    --     player.addStatus(name, value)
    -- end
end

---@diagnostic disable-next-line: duplicate-set-field
function client.setPlayerData(key, value)
    PlayerData[key] = value
    OnPlayerData(key, value)
end