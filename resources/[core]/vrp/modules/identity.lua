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

function vRP.getPlayerIdentity(user_id, offline)
  if not next(vRP.user_tables[user_id] or {}) then
    if offline then
      local character = vRP.getCharacter(user_id, false)
      if character then
        local birth_date = os.date("%d-%m-%Y", character.birth_date // 1000)
        return {
          user_id = character.user_id,
          char_id = character.id,
          phone = character.phone,
          registration = character.registration,
          firstname = character.firstname,
          birth_date = birth_date,
          lastname = character.lastname,
          license = character.license,
          gender = character.gender,
          job = {}
        }
      end
    end
    return nil
  end
  local xPlayer = vRP.user_tables[user_id]
  local birth_date = os.date("%d-%m-%Y", xPlayer.birth_date // 1000)
  local jobName, jobData = vRP.getUserGroupByType(xPlayer.user_id, 'job')
  return {
    user_id = xPlayer.user_id,
    char_id = xPlayer.id,
    phone = xPlayer.phone,
    registration = xPlayer.registration,
    firstname = xPlayer.firstname,
    birth_date = birth_date,
    lastname = xPlayer.lastname,
    license = xPlayer.license,
    gender = xPlayer.gender,
    job = jobName and { name = jobName, rank = jobData.rank, onduty = jobData.duty } or {}
  }
end

function vRP.getUserIdentity(user_id)
  return vRP.getPlayerIdentity(user_id, false)
end
