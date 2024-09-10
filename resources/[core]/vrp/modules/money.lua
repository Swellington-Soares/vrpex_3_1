function vRP.getMoney(user_id, moneytype)  
  moneytype = moneytype or 'cash'
  return vRP.getPlayerTable(user_id)?.money[moneytype] or 0.0
end

-- set money
function vRP.setMoney(user_id, value, moneytype, reason, notify)
  moneytype = moneytype or 'cash'
  local src = vRP.getUserSource(user_id)
  local player = vRP.getPlayerTable(user_id)
  if not player then
    return false
  end

  player.money[moneytype] = value >= 0 and value or 0
  if notify and reason then
    vRP.notify(source, 'Money', reason, 5000, "inform")
  end

  TriggerEvent('vRP:PlayerMoneyUpdate', user_id, value, moneytype)
  TriggerClientEvent('vRP:client:PlayerMoneyUpdate', src, value, moneytype)
  return true
end

-- try a payment
-- return true or false (debited if true)
function vRP.tryPayment(user_id, amount, reason, notify)
  local money = vRP.getMoney(user_id)
  if amount >= 0 and money >= amount then
    return vRP.setMoney(user_id, money - amount, 'cash', reason, notify)     
  else
    return false
  end
end

function vRP.removeMoney(user_id, amount, moneytype, reason, notify)
  local money = vRP.getMoney(user_id, moneytype)
  if money > 0 and amount > 0 and money >= amount then
      return vRP.setMoney(user_id, money - amount, moneytype, reason, notify)
  end
  return false
end

-- give money
function vRP.giveMoney(user_id, amount, moneytype, reason, notify)
  if amount > 0 then
    local money = vRP.getMoney(user_id)
    return vRP.setMoney(user_id, money + amount, moneytype, reason, notify)
  end
  return false
end

-- get bank money
function vRP.getBankMoney(user_id)
  return vRP.getMoney(user_id, 'bank')
end

-- set bank money
function vRP.setBankMoney(user_id, value, reason, notify)
 return vRP.setMoney(user_id, value, 'bank', reason, notify)
end

-- give bank money
function vRP.giveBankMoney(user_id, amount, reason, notify)
  return vRP.giveMoney(user_id, amount, 'bank', reason, notify)
end

function vRP.removeBankMoney(user_id, amount, reason, notify)
  return vRP.removeMoney(user_id, amount, 'bank', reason, notify)
end

-- try a withdraw
-- return true or false (withdrawn if true)
function vRP.tryWithdraw(user_id, amount)
  local money = vRP.getMoney(user_id, 'bank')
  if amount >= 0 and money >= amount then
    vRP.setBankMoney(user_id, money - amount)
    vRP.giveMoney(user_id, amount)
    return true
  else
    return false
  end
end

-- try a deposit
-- return true or false (deposited if true)
function vRP.tryDeposit(user_id, amount)
  if amount >= 0 and vRP.tryPayment(user_id, amount) then
    return vRP.giveBankMoney(user_id, amount)    
  else
    return false
  end
end

function vRP.tryFullPayment(user_id, amount)
  local money = vRP.getMoney(user_id)
  if money >= amount then                          -- enough, simple payment
    return vRP.tryPayment(user_id, amount)
  else                                             -- not enough, withdraw -> payment
    if vRP.tryWithdraw(user_id, amount - money) then -- withdraw to complete amount
      return vRP.tryPayment(user_id, amount)
    end
  end

  return false
end
