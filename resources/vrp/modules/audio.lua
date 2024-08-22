local cfg = module('cfg/base')

if cfg.allow_audio_player_from_client then
    RegisterNetEvent('chHyperSound:play')
    RegisterNetEvent('chHyperSound:playOnEntity')
    RegisterNetEvent('chHyperSound:stop')
end

AddEventHandler('chHyperSound:play', function(soundId, soundName, isLooped, location, maxDistance, targetId)
    if not maxDistance then
        maxDistance = Config.DefaultDistance
    end

    if not targetId then
        targetId = -1
    end

    TriggerClientEvent('__chHyperSound:play', targetId, soundId, soundName, isLooped, location, maxDistance)
end)

AddEventHandler('chHyperSound:playOnEntity', function(entityNetId, soundId, soundName, isLooped, maxDistance, targetId)
    if not maxDistance then
        maxDistance = Config.DefaultDistance
    end

    if not targetId then
        targetId = -1
    end

    TriggerClientEvent('__chHyperSound:playOnEntity', targetId, entityNetId, soundId, soundName, isLooped, maxDistance)
end)

AddEventHandler('chHyperSound:stop', function(soundId, targetId)
    if not targetId then
        targetId = -1
    end

    TriggerClientEvent('__chHyperSound:stop', targetId, soundId)
end)



--vrpex
function tvRP.playSound(id, name, looped, location, maxDistance, target)
    TriggerEvent('chHyperSound:play', id, name, looped, location, maxDistance, target)
end

function tvRP.stopSound(id, target)
     TriggerEvent('chHyperSound:stop', id, target)
end

function tvRP.playSoundOnEntity(entityNetId, soundId, soundName, isLooped, maxDistance, targetId)
    TriggerEvent('chHyperSound:stop', entityNetId, soundId, soundName, isLooped, maxDistance, targetId)
end