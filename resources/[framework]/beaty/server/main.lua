RegisterNetEvent('beaty:checkpayment', function()
    local source = source
    if GetInvokingResource() then return end
    local user_id = vRP.getUserId(source)    
    if not user_id then return end
    vRP.removeMoney(user_id, 500, 'cash', 'Compra na Loja de Beleza')
end)