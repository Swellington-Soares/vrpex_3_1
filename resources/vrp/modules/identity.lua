local cfg = module("cfg/base")

-- api

function vRP.generateStringNumber(format) -- (ex: DDDLLL, D => digit, L => letter)
  local abyte = string.byte("A")
  local zbyte = string.byte("0")

  local number = ""
  for i=1,#format do
    local char = string.sub(format, i,i)
    if char == "D" then number = number..string.char(zbyte+math.random(0,9))
    elseif char == "L" then number = number..string.char(abyte+math.random(0,25))
    else number = number..char end
  end

  return number
end


-- -- events, init user identity at connection
-- AddEventHandler("vRP:playerJoin",function(user_id,source,name,last_login)
--   if not vRP.getUserIdentity(user_id) then
--     local registration = vRP.generateRegistrationNumber()
--     local phone = vRP.generatePhoneNumber()
--     vRP.execute("vRP/init_user_identity", {
--       user_id = user_id,
--       registration = registration,
--       phone = phone,
--       -- firstname = cfg.random_first_names[math.random(1,#cfg.random_first_names)],
--       -- name = cfg.random_last_names[math.random(1,#cfg.random_last_names)],
--       age = math.random(25,40)
--     })
--   end
-- end)

