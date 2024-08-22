local function PedKilledByPlayer(victim, player, weapon, isMelee)
    print("PedKilledByPlayer", victim, player, weapon, isMelee)
end

local function PedKilledByPed(victim, attacker, weapon, isMelee)
    print("PedKilledByPed", victim, attacker, weapon, isMelee)
end

local function PedKilledByVehicle(victim, attacker)
    print("PedKilledByVehicle", victim, attacker)
end


local function PedDied(victim, attacker, weapon, isMelee)
    print("PedDied", victim, attacker, weapon, isMelee)
end

AddEventHandler('gameEventTriggered', function(event, data)    

    print(event, json.encode(data))

    if event == 'CEventNetworkEntityDamage' then
        local victim = tonumber(data[1])
        local attacker = tonumber(data[2])
        local victimDied = tonumber(data[4]) == 1
        local weapon = tonumber(data[7])
        local isMelee = tonumber(data[11]) ~= 0
        -- local vehicleDamageTypeFlag = tonumber(data[12])
        if victim ~= nil and attacker ~= nil and victim == PlayerPedId() then
            if victimDied then
                if IsEntityAPed(victim) and IsPedAPlayer(victim) then
                    if IsEntityAVehicle(attacker) then
                        PedKilledByVehicle(victim, attacker)
                    elseif IsEntityAPed(attacker) then
                        if IsPedAPlayer(attacker) then
                            local player = NetworkGetPlayerIndexFromPed(attacker)
                            PedKilledByPlayer(victim, player, weapon, isMelee)
                        else
                            PedKilledByPed(victim, attacker, weapon, isMelee)
                        end
                    else
                        PedDied(victim, attacker, weapon, isMelee)
                    end
                end
            end
        end
    end
end)