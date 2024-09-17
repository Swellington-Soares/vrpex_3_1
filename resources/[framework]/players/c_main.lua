lib.onCache('vehicle', function(value)
    if not value then return end
    SetVehicleWeaponCapacity(value, 0, 0)
    SetVehicleWeaponCapacity(value, 1, 0)
end)
