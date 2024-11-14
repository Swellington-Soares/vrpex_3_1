local cfg = module('cfg/base')
local block = require('@vrp.cfg.block')

local relationMode = cfg?.hate_mode and 5 or 1

--custom natives
local function DISABLE_PLAYER_HEALTH_RECHARGE(playerId) Citizen.InvokeNative(0xBCB06442F7E52666, playerId) end


--  Relationship Types:
--  0 = Companion
--  1 = Respect
--  2 = Like
--  3 = Neutral
--  4 = Dislike
--  5 = Hate
SetRelationshipBetweenGroups(relationMode, `AMBIENT_GANG_HILLBILLY`, `PLAYER`)
SetRelationshipBetweenGroups(relationMode, `AMBIENT_GANG_BALLAS`, `PLAYER`)
SetRelationshipBetweenGroups(relationMode, `AMBIENT_GANG_MEXICAN`, `PLAYER`)
SetRelationshipBetweenGroups(relationMode, `AMBIENT_GANG_FAMILY`, `PLAYER`)
SetRelationshipBetweenGroups(relationMode, `AMBIENT_GANG_MARABUNTE`, `PLAYER`)
SetRelationshipBetweenGroups(relationMode, `AMBIENT_GANG_SALVA`, `PLAYER`)
SetRelationshipBetweenGroups(relationMode, `AMBIENT_GANG_LOST`, `PLAYER`)
SetRelationshipBetweenGroups(relationMode, `GANG_1`, `PLAYER`)
SetRelationshipBetweenGroups(relationMode, `GANG_2`, `PLAYER`)
SetRelationshipBetweenGroups(relationMode, `GANG_9`, `PLAYER`)
SetRelationshipBetweenGroups(relationMode, `GANG_10`, `PLAYER`)
SetRelationshipBetweenGroups(relationMode, `FIREMAN`, `PLAYER`)
SetRelationshipBetweenGroups(relationMode, `MEDIC`, `PLAYER`)
SetRelationshipBetweenGroups(relationMode, `COP`, `PLAYER`)
SetRelationshipBetweenGroups(relationMode, `PRISONER`, `PLAYER`)

CreateThread(function()    
    local stealthKills <const> = {
        `ACT_stealth_kill_a`,
        `ACT_stealth_kill_weapon`,
        `ACT_stealth_kill_b`,
        `ACT_stealth_kill_c`,
        `ACT_stealth_kill_d`,
        `ACT_stealth_kill_a_gardene`
    }
    for _, killName in ipairs(stealthKills) do
        RemoveStealthKill(killName, false)
    end


    for i = 1, 15 do
        EnableDispatchService(i, false)
    end
   
    local mapText = cfg.pause_menu_text
    if mapText == '' or type(mapText) ~= 'string' then mapText = 'FiveM' end
    Citizen.InvokeNative(joaat('ADD_TEXT_ENTRY'), 'FE_THDR_GTAO', mapText)
    
end)


CreateThread(function()

    if cfg.disables.disable_auto_swap_weapon then
        SetWeaponsNoAutoswap(true)
    end

    if cfg.disables.disable_auto_reload then
        SetWeaponsNoAutoreload(true)
    end


    if cfg.disables.idlecam then
        while true do
            InvalidateIdleCam()
            InvalidateVehicleIdleCam()
            Wait(20000)
        end
    end
end)


Citizen.CreateThread(function()
    if GetGameBuildNumber() >= 2802 then
        DISABLE_PLAYER_HEALTH_RECHARGE(cache.playerId)
    else
        while true do
            Citizen.Wait(100)
            SetPlayerHealthRechargeMultiplier(PlayerId(), 0.0)
        end
    end
end)

CreateThread(function()
    while true do
        local pedPool = GetGamePool('CPed')
        for _, v in pairs(pedPool) do
            SetPedDropsWeaponsWhenDead(v, false)
            local weapon = GetSelectedPedWeapon(v)
            if block?.weapons[weapon] then
                RemoveWeaponFromPed(v, weapon)
            end
        end
        Wait(10000)
    end
end)

AddEventHandler('populationPedCreating', function(x, y, z, model)
    Wait(1000)
    if block?.peds[model] then
        CancelEvent()
    else
        local ped = lib.getClosestPed(vec3(x, y, z), 1.0)
        if ped then
            SetPedDropsWeaponsWhenDead(ped, false)
        end
    end
end)


local disabledPickups = {
    `PICKUP_WEAPON_BULLPUPSHOTGUN`,
    `PICKUP_WEAPON_ASSAULTSMG`,
    `PICKUP_VEHICLE_WEAPON_ASSAULTSMG`,
    `PICKUP_WEAPON_PISTOL50`,
    `PICKUP_VEHICLE_WEAPON_PISTOL50`,
    `PICKUP_AMMO_BULLET_MP`,
    `PICKUP_AMMO_MISSILE_MP`,
    `PICKUP_AMMO_GRENADELAUNCHER_MP`,
    `PICKUP_WEAPON_ASSAULTRIFLE`,
    `PICKUP_WEAPON_CARBINERIFLE`,
    `PICKUP_WEAPON_ADVANCEDRIFLE`,
    `PICKUP_WEAPON_MG`,
    `PICKUP_WEAPON_COMBATMG`,
    `PICKUP_WEAPON_SNIPERRIFLE`,
    `PICKUP_WEAPON_HEAVYSNIPER`,
    `PICKUP_WEAPON_MICROSMG`,
    `PICKUP_WEAPON_SMG`,
    `PICKUP_ARMOUR_STANDARD`,
    `PICKUP_WEAPON_RPG`,
    `PICKUP_WEAPON_MINIGUN`,
    `PICKUP_HEALTH_STANDARD`,
    `PICKUP_WEAPON_PUMPSHOTGUN`,
    `PICKUP_WEAPON_SAWNOFFSHOTGUN`,
    `PICKUP_WEAPON_ASSAULTSHOTGUN`,
    `PICKUP_WEAPON_GRENADE`,
    `PICKUP_WEAPON_MOLOTOV`,
    `PICKUP_WEAPON_SMOKEGRENADE`,
    `PICKUP_WEAPON_STICKYBOMB`,
    `PICKUP_WEAPON_PISTOL`,
    `PICKUP_WEAPON_COMBATPISTOL`,
    `PICKUP_WEAPON_APPISTOL`,
    `PICKUP_WEAPON_GRENADELAUNCHER`,
    `PICKUP_MONEY_VARIABLE`,
    `PICKUP_GANG_ATTACK_MONEY`,
    `PICKUP_WEAPON_STUNGUN`,
    `PICKUP_WEAPON_PETROLCAN`,
    `PICKUP_WEAPON_KNIFE`,
    `PICKUP_WEAPON_NIGHTSTICK`,
    `PICKUP_WEAPON_HAMMER`,
    `PICKUP_WEAPON_BAT`,
    `PICKUP_WEAPON_GolfClub`,
    `PICKUP_WEAPON_CROWBAR`,
    `PICKUP_CUSTOM_SCRIPT`,
    `PICKUP_CAMERA`,
    `PICKUP_PORTABLE_PACKAGE`,
    `PICKUP_PORTABLE_CRATE_UNFIXED`,
    `PICKUP_PORTABLE_PACKAGE_LARGE_RADIUS`,
    `PICKUP_PORTABLE_CRATE_UNFIXED_INCAR`,
    `PICKUP_PORTABLE_CRATE_UNFIXED_INAIRVEHICLE_WITH_PASSENGERS`,
    `PICKUP_PORTABLE_CRATE_UNFIXED_INAIRVEHICLE_WITH_PASSENGERS_UPRIGHT`,
    `PICKUP_PORTABLE_CRATE_UNFIXED_INCAR_WITH_PASSENGERS`,
    `PICKUP_PORTABLE_CRATE_FIXED_INCAR_WITH_PASSENGERS`,
    `PICKUP_PORTABLE_CRATE_FIXED_INCAR_SMALL`,
    `PICKUP_PORTABLE_CRATE_UNFIXED_INCAR_SMALL`,
    `PICKUP_PORTABLE_CRATE_UNFIXED_LOW_GLOW`,
    `PICKUP_MONEY_CASE`,
    `PICKUP_MONEY_WALLET`,
    `PICKUP_MONEY_PURSE`,
    `PICKUP_MONEY_DEP_BAG`,
    `PICKUP_MONEY_MED_BAG`,
    `PICKUP_MONEY_PAPER_BAG`,
    `PICKUP_MONEY_SECURITY_CASE`,
    `PICKUP_VEHICLE_WEAPON_COMBATPISTOL`,
    `PICKUP_VEHICLE_WEAPON_APPISTOL`,
    `PICKUP_VEHICLE_WEAPON_PISTOL`,
    `PICKUP_VEHICLE_WEAPON_GRENADE`,
    `PICKUP_VEHICLE_WEAPON_MOLOTOV`,
    `PICKUP_VEHICLE_WEAPON_SMOKEGRENADE`,
    `PICKUP_VEHICLE_WEAPON_STICKYBOMB`,
    `PICKUP_VEHICLE_HEALTH_STANDARD`,
    `PICKUP_VEHICLE_HEALTH_STANDARD_LOW_GLOW`,
    `PICKUP_VEHICLE_ARMOUR_STANDARD`,
    `PICKUP_VEHICLE_WEAPON_MICROSMG`,
    `PICKUP_VEHICLE_WEAPON_SMG`,
    `PICKUP_VEHICLE_WEAPON_SAWNOFF`,
    `PICKUP_VEHICLE_CUSTOM_SCRIPT`,
    `PICKUP_VEHICLE_CUSTOM_SCRIPT_NO_ROTATE`,
    `PICKUP_VEHICLE_CUSTOM_SCRIPT_LOW_GLOW`,
    `PICKUP_VEHICLE_MONEY_VARIABLE`,
    `PICKUP_SUBMARINE`,
    `PICKUP_HEALTH_SNACK`,
    `PICKUP_PARACHUTE`,
    `PICKUP_AMMO_PISTOL`,
    `PICKUP_AMMO_SMG`,
    `PICKUP_AMMO_RIFLE`,
    `PICKUP_AMMO_MG`,
    `PICKUP_AMMO_SHOTGUN`,
    `PICKUP_AMMO_SNIPER`,
    `PICKUP_AMMO_GRENADELAUNCHER`,
    `PICKUP_AMMO_RPG`,
    `PICKUP_AMMO_MINIGUN`,
    `PICKUP_WEAPON_BOTTLE`,
    `PICKUP_WEAPON_SNSPISTOL`,
    `PICKUP_WEAPON_HEAVYPISTOL`,
    `PICKUP_WEAPON_SPECIALCARBINE`,
    `PICKUP_WEAPON_BULLPUPRIFLE`,
    `PICKUP_WEAPON_RAYPISTOL`,
    `PICKUP_WEAPON_RAYCARBINE`,
    `PICKUP_WEAPON_RAYMINIGUN`,
    `PICKUP_WEAPON_BULLPUPRIFLE_MK2`,
    `PICKUP_WEAPON_DOUBLEACTION`,
    `PICKUP_WEAPON_MARKSMANRIFLE_MK2`,
    `PICKUP_WEAPON_PUMPSHOTGUN_MK2`,
    `PICKUP_WEAPON_REVOLVER_MK2`,
    `PICKUP_WEAPON_SNSPISTOL_MK2`,
    `PICKUP_WEAPON_SPECIALCARBINE_MK2`,
    `PICKUP_WEAPON_PROXMINE`,
    `PICKUP_WEAPON_HOMINGLAUNCHER`,
    `PICKUP_AMMO_HOMINGLAUNCHER`,
    `PICKUP_WEAPON_GUSENBERG`,
    `PICKUP_WEAPON_DAGGER`,
    `PICKUP_WEAPON_VINTAGEPISTOL`,
    `PICKUP_WEAPON_FIREWORK`,
    `PICKUP_WEAPON_MUSKET`,
    `PICKUP_AMMO_FIREWORK`,
    `PICKUP_AMMO_FIREWORK_MP`,
    `PICKUP_PORTABLE_DLC_VEHICLE_PACKAGE`,
    `PICKUP_WEAPON_HATCHET`,
    `PICKUP_WEAPON_RAILGUN`,
    `PICKUP_WEAPON_HEAVYSHOTGUN`,
    `PICKUP_WEAPON_MARKSMANRIFLE`,
    `PICKUP_WEAPON_CERAMICPISTOL`,
    `PICKUP_WEAPON_HAZARDCAN`,
    `PICKUP_WEAPON_NAVYREVOLVER`,
    `PICKUP_WEAPON_COMBATSHOTGUN`,
    `PICKUP_WEAPON_GADGETPISTOL`,
    `PICKUP_WEAPON_MILITARYRIFLE`,
    `PICKUP_WEAPON_FLAREGUN`,
    `PICKUP_AMMO_FLAREGUN`,
    `PICKUP_WEAPON_KNUCKLE`,
    `PICKUP_WEAPON_MARKSMANPISTOL`,
    `PICKUP_WEAPON_COMBATPDW`,
    `PICKUP_PORTABLE_CRATE_FIXED_INCAR`,
    `PICKUP_WEAPON_COMPACTRIFLE`,
    `PICKUP_WEAPON_DBSHOTGUN`,
    `PICKUP_WEAPON_MACHETE`,
    `PICKUP_WEAPON_MACHINEPISTOL`,
    `PICKUP_WEAPON_FLASHLIGHT`,
    `PICKUP_WEAPON_REVOLVER`,
    `PICKUP_WEAPON_SWITCHBLADE`,
    `PICKUP_WEAPON_AUTOSHOTGUN`,
    `PICKUP_WEAPON_BATTLEAXE`,
    `PICKUP_WEAPON_COMPACTLAUNCHER`,
    `PICKUP_WEAPON_MINISMG`,
    `PICKUP_WEAPON_PIPEBOMB`,
    `PICKUP_WEAPON_POOLCUE`,
    `PICKUP_WEAPON_WRENCH`,
    `PICKUP_WEAPON_ASSAULTRIFLE_MK2`,
    `PICKUP_WEAPON_CARBINERIFLE_MK2`,
    `PICKUP_WEAPON_COMBATMG_MK2`,
    `PICKUP_WEAPON_HEAVYSNIPER_MK2`,
    `PICKUP_WEAPON_PISTOL_MK2`,
    `PICKUP_WEAPON_SMG_MK2`,
    `PICKUP_WEAPON_STONE_HATCHET`,
    `PICKUP_WEAPON_METALDETECTOR`,
    `PICKUP_WEAPON_TACTICALRIFLE`,
    `PICKUP_WEAPON_PRECISIONRIFLE`,
    `PICKUP_WEAPON_EMPLAUNCHER`,
    `PICKUP_AMMO_EMPLAUNCHER`,
    `PICKUP_WEAPON_HEAVYRIFLE`,
    `PICKUP_WEAPON_PETROLCAN_SMALL_RADIUS`,
    `PICKUP_WEAPON_FERTILIZERCAN`,
    `PICKUP_WEAPON_STUNGUN_MP`,
}

CreateThread(function()
    for i = 1, #disabledPickups do
        ToggleUsePickupsForPlayer(PlayerId(), disabledPickups[i], false)
        RemoveAllPickupsOfType(disabledPickups[i])
    end


    for k in next, block?.weapons or {} do
        SetCanPedEquipWeapon(cache.ped, k, false)
    end
end)

lib.onCache('weapon', function(value)
    if value then
        if block?.weapons[value] then
            RemoveWeaponFromPed(PlayerPedId(), value)
        end
        if value ~= `WEAPON_UNARMED` then
            TriggerServerEvent('vrp:server:WeaponChangeNotify', value)
        end
    end
    Wait(0)
end)

lib.onCache('ped', function(value)
    if value then 
        if LocalPlayer.state.isLoggedIn then
            vRP.setPedFlags(value)
        end

        for k in next, block?.weapons or {} do
            SetCanPedEquipWeapon(value, k, false)
            RemoveWeaponFromPed(value, k)
        end

        SetPedDropsWeaponsWhenDead(value, false)
    end
    Wait(0)
end)

lib.onCache('vehicle', function(value)
    if not value then return end
    DisablePlayerVehicleRewards(cache.playerId)
    SetVehicleWeaponCapacity(value, 0, 0)
    SetVehicleWeaponCapacity(value, 1, 0)
    Wait(0)
end)
