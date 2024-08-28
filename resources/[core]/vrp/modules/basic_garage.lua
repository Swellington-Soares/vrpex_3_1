function tvRP.spawnVehicle(model, pos, _type)

    local vehicle = CreateVehicleServerSetter(model, _type or 'automobile', pos.x, pos.y, pos.z, pos?.w or 0.0)
    while not DoesEntityExist(vehicle) do Wait(10) end
    return vehicle
end