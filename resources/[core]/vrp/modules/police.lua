
---INTERNAL USAGE DO NOT EDIT
RegisterNetEvent('vrp:server:GunShotNotify', function (w, a)
    if GetInvokingResource() then return end
    local source = source
    local ped = GetPlayerPed( source )
    local pos = GetEntityCoords(ped)
    local weaponInfo =     nil
    TriggerEvent('vrp:GunShotNotify', source, ped, pos, weaponInfo, a)
end)


function vRP.setPlayerHandcuffed( source, state )
    if DoesPlayerExist( source ) then
        Player( source ).state:set('handcuffed', state, true)
    end
end