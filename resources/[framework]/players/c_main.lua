lib.onCache('vehicle', function(value)
    if not value then return end
    SetVehicleWeaponCapacity(value, 0, 0)
    SetVehicleWeaponCapacity(value, 1, 0)
end)

CreateThread(function()
    SetMaxWantedLevel(0)
    SetPlayerCanDoDriveBy(cache.playerId, true)
    NetworkSetLocalPlayerSyncLookAt(true)
    Wait(0)
end)

CreateThread(function() -- all these should only need to be called once
    -- while true do
    print('OKOK')
    StartAudioScene('CHARACTER_CHANGE_IN_SKY_SCENE')
    StartAudioScene('DLC_MPHEIST_TRANSITION_TO_APT_FADE_IN_RADIO_SCENE')
    SetStaticEmitterEnabled('LOS_SANTOS_VANILLA_UNICORN_01_STAGE', false)
    SetStaticEmitterEnabled('LOS_SANTOS_VANILLA_UNICORN_02_MAIN_ROOM', false)
    SetStaticEmitterEnabled('LOS_SANTOS_VANILLA_UNICORN_03_BACK_ROOM', false)
    SetAmbientZoneListStatePersistent('AZL_DLC_Hei4_Island_Disabled_Zones', false, true)
    SetAmbientZoneListStatePersistent('AZL_DLC_Hei4_Island_Zones', true, true)
    SetScenarioTypeEnabled('WORLD_VEHICLE_STREETRACE', false)
    SetScenarioTypeEnabled('WORLD_VEHICLE_SALTON_DIRT_BIKE', false)
    SetScenarioTypeEnabled('WORLD_VEHICLE_SALTON', false)
    SetScenarioTypeEnabled('WORLD_VEHICLE_POLICE_NEXT_TO_CAR', false)
    SetScenarioTypeEnabled('WORLD_VEHICLE_POLICE_CAR', false)
    SetScenarioTypeEnabled('WORLD_VEHICLE_POLICE_BIKE', false)
    SetScenarioTypeEnabled('WORLD_VEHICLE_MILITARY_PLANES_SMALL', false)
    SetScenarioTypeEnabled('WORLD_VEHICLE_MILITARY_PLANES_BIG', false)
    SetScenarioTypeEnabled('WORLD_VEHICLE_MECHANIC', false)
    SetScenarioTypeEnabled('WORLD_VEHICLE_EMPTY', false)
    SetScenarioTypeEnabled('WORLD_VEHICLE_BUSINESSMEN', false)
    SetScenarioTypeEnabled('WORLD_VEHICLE_BIKE_OFF_ROAD_RACE', false)
    StartAudioScene('FBI_HEIST_H5_MUTE_AMBIENCE_SCENE')
    StartAudioScene('CHARACTER_CHANGE_IN_SKY_SCENE')
    SetAudioFlag('PoliceScannerDisabled', true)
    SetAudioFlag('DisableFlightMusic', true)
    -- SetPlayerCanUseCover(PlayerId(),false)
    SetRandomEventFlag(false)
    SetDeepOceanScaler(0.0)
    SetGarbageTrucks(false)
    SetCreateRandomCops(false)
    SetCreateRandomCopsNotOnScenarios(false)
    SetCreateRandomCopsOnScenarios(false)
    DistantCopCarSirens(false)
    -- REMOVE CHOPPERS WOW
    Wait(0)
    -- end
end)

CreateThread(function()
        RemoveVehiclesFromGeneratorsInArea(335.2616 - 300.0, -1432.455 - 300.0, 46.51 - 300.0, 335.2616 + 300.0,
            -1432.455 + 300.0, 46.51 + 300.0) -- central los santos medical center
        RemoveVehiclesFromGeneratorsInArea(441.8465 - 500.0, -987.99 - 500.0, 30.68 - 500.0, 441.8465 + 500.0,
            -987.99 + 500.0, 30.68 + 500.0) -- police station mission row
        RemoveVehiclesFromGeneratorsInArea(316.79 - 300.0, -592.36 - 300.0, 43.28 - 300.0, 316.79 + 300.0,
            -592.36 + 300.0,
            43.28 + 300.0)            -- pillbox
        RemoveVehiclesFromGeneratorsInArea(-2150.44 - 500.0, 3075.99 - 500.0, 32.8 - 500.0, -2150.44 + 500.0,
            -3075.99 + 500.0, 32.8 + 500.0) -- military
        RemoveVehiclesFromGeneratorsInArea(-1108.35 - 300.0, 4920.64 - 300.0, 217.2 - 300.0, -1108.35 + 300.0,
            4920.64 + 300.0, 217.2 + 300.0) -- nudist
        RemoveVehiclesFromGeneratorsInArea(-458.24 - 300.0, 6019.81 - 300.0, 31.34 - 300.0, -458.24 + 300.0,
            6019.81 + 300.0,
            31.34 + 300.0)            -- police station paleto
        RemoveVehiclesFromGeneratorsInArea(1854.82 - 300.0, 3679.4 - 300.0, 33.82 - 300.0, 1854.82 + 300.0,
            3679.4 + 300.0,
            33.82 + 300.0)            -- police station sandy
        RemoveVehiclesFromGeneratorsInArea(-724.46 - 300.0, -1444.03 - 300.0, 5.0 - 300.0, -724.46 + 300.0,
            -1444.03 + 300.0,
            5.0 + 300.0)
end)
