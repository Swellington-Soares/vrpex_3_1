function vRP.getMoney(user_id, moneytype)
  moneytype = moneytype or 'wallet'
  return vRP.getUserDataTable(user_id)?.money[moneytype] or 0.0
end

-- set money
function vRP.setMoney(user_id, value, moneytype, reason, notify)
  moneytype = moneytype or 'wallet'
  local datatable = vRP.getUserDataTable(user_id)
  if not datatable then
    return false
  end

  if datatable.money[moneytype] ~= nil then
    datatable.money[moneytype] = value
  end

  if notify and reason then
    local source = vRP.getUserSource(user_id)
    vRPclient._Notify(source, reason, "info", 3000)
  end

  return true
end

-- try a payment
-- return true or false (debited if true)
function vRP.tryPayment(user_id, amount)
  local money = vRP.getMoney(user_id)
  if amount >= 0 and money >= amount then
    vRP.setMoney(user_id, money - amount)
    return true
  else
    return false
  end
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
    vRP.giveBankMoney(user_id, amount)
    return true
  else
    return false
  end
end

-- try full payment (wallet + bank to complete payment)
-- return true or false (debited if true)
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
