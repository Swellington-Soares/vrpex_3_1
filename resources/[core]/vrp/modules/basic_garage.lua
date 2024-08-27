local pp = json.decode(
    [[
{
    "pearlescentColor": 5,
    "modHorns": 2,
    "modRoof": 0,
    "engineHealth": 1000,
    "modEngineBlock": -1,
    "modSuspension": -1,
    "modBackWheels": -1,
    "modLightbar": -1,
    "modDoorR": -1,
    "neonEnabled": [
        true,
        true,
        true,
        true
    ],
    "modSpoilers": 11,
    "modRearBumper": 0,
    "model": -1403128555,
    "modStruts": -1,
    "modRoofLivery": -1,
    "modVanityPlate": -1,
    "dirtLevel": 5,
    "modTank": -1,
    "modSideSkirt": 4,
    "bulletProofTyres": false,
    "modTransmission": 2,
    "windows": [
        2,
        3,
        4,
        5,
        7
    ],
    "modAPlate": -1,
    "interiorColor": 9,
    "dashboardColor": 6,
    "wheelColor": 7,
    "neonColor": [
        94,
        255,
        1
    ],
    "modFrontBumper": 0,
    "modTrimB": -1,
    "modTrunk": -1,
    "tankHealth": 1000,
    "modXenon": true,
    "doors": [],
    "modArchCover": -1,
    "modOrnaments": -1,
    "modSteeringWheel": -1,
    "modSpeakers": -1,
    "modBrakes": 2,
    "fuelLevel": 65,
    "wheelSize": 0.68999999761581,
    "modFender": 0,
    "oilLevel": 5,
    "modSeats": -1,
    "paintType2": 7,
    "modEngine": 3,
    "modExhaust": 1,
    "plateIndex": 1,
    "modCustomTiresR": false,
    "bodyHealth": 1000,
    "modRightFender": 1,
    "modPlateHolder": -1,
    "modAirFilter": -1,
    "modSubwoofer": -1,
    "xenonColor": 2,
    "modShifterLeavers": -1,
    "modSmokeEnabled": true,
    "modDoorSpeaker": -1,
    "modHydrolic": -1,
    "modTrimA": -1,
    "tyreSmokeColor": [
        181,
        120,
        0
    ],
    "tyres": [],
    "modGrille": 0,
    "modTurbo": true,
    "modHydraulics": false,
    "modArmor": 4,
    "modFrontWheels": 33,
    "extras": [],
    "plate": "65SKA918",
    "modFrame": 0,
    "windowTint": 2,
    "modDial": -1,
    "color1": 11,
    "modNitrous": -1,
    "modLivery": 11,
    "modAerials": -1,
    "wheelWidth": 0.61999750137329,
    "wheels": 7,
    "modHood": 2,
    "modDashboard": -1,
    "paintType1": 7,
    "color2": 41,
    "modWindows": -1,
    "modCustomTiresF": true,
    "driftTyres": false
}
]]
)


function vRP.spawnVehicle(model, pos)
    lib.print.info(model, pos)
    local vehicle = CreateVehicleServerSetter(model, 'automobile', pos.x, pos.y, pos.z, pos?.w or 0.0)
    while not DoesEntityExist(vehicle) do Wait(10) end
    return vehicle
end

lib.callback.register('vrp:server:spawnvehicle', function(source, model, pos)
    local vehicle = vRP.spawnVehicle(model, pos)
    Entity(vehicle).state:set('vehicle:owner', source, true)
    Wait(1000)
    Entity(vehicle).state:set('vehicle:property', pp, true)
    return NetworkGetNetworkIdFromEntity(vehicle)
end)
