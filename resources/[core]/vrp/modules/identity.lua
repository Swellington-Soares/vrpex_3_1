local cfg = module("cfg/base")

-- api

function vRP.generateStringNumber(format) -- (ex: DDDLLL, D => digit, L => letter)
  local abyte = string.byte("A")
  local zbyte = string.byte("0")

  local number = ""
  for i = 1, #format do
    local char = string.sub(format, i, i)
    if char == "D" then
      number = number .. string.char(zbyte + math.random(0, 9))
    elseif char == "L" then
      number = number .. string.char(abyte + math.random(0, 25))
    else
      number = number .. char
    end
  end

  return number
end

function vRP.getPlayerIdentity(user_id)
  if not next(vRP.user_tables[user_id] or {}) then return end
  local xPlayer = vRP.user_tables[user_id]
  local birth_date = os.date("%d-%m-%Y", xPlayer.birth_date // 1000)
  return {
    user_id = xPlayer.user_id,
    char_id = xPlayer.id,
    phone = xPlayer.phone,
    registration = xPlayer.registration,
    firstname = xPlayer.firstname,
    birth_date = birth_date,
    lastname = xPlayer.lastname,
    license = xPlayer.license
  }

end
