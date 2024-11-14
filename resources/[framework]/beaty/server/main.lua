local config = BeatyConfig

RegisterNetEvent('beaty:checkpayment', function()
    local source = source
    if GetInvokingResource() then return end
    local user_id = vRP.getUserId(source)    
    if not user_id then return end
    vRP.removeMoney(user_id, 500, 'cash', 'Compra na Loja de Beleza')
end)

RegisterNetEvent('beaty:savepreset', function(preset)
    local source = source
    if GetInvokingResource() then return end

    local user_id = vRP.getUserId(source)    
    local char_id = vRP.getCharId( source )    
    if not user_id or not char_id then return end

    vRP.removeMoney(user_id, config.save_preset_price or 1000, 'cash', 'Criação de Preset')

    local presetId = 'preset_' .. char_id .. '_' .. lib.string.random('A111AA1A1A1')
    vRP.setPlayerData(char_id, presetId, preset)
    exports.ox_inventory:AddItem(source, 'preset', 1, { preset_id = presetId })
end)


lib.callback.register('beaty:server:getPreset', function(source, preset_id)
    local char_id = vRP.getCharId( source )
    if not char_id then return false end

    local preset = vRP.getPlayerData(char_id, preset_id)
    preset = preset and json.decode(preset) or false

    return preset
end)