
-- define aptitude system (aka. education, skill system)

local cfg = module("cfg/aptitudes")


-- exp notes:
-- levels are defined by the amount of xp
-- with a step of 5: 5|15|30|50|75
-- total exp for a specific level, exp = step*lvl*(lvl+1)/2
-- level for a specific exp amount, lvl = (sqrt(1+8*exp/step)-1)/2

local exp_step = 5

local gaptitudes = {}

function vRP.defAptitudeGroup(group, title)
  gaptitudes[group] = {_title = title}
end

-- max_exp: -1 => infinite
function vRP.defAptitude(group, aptitude, title, init_exp, max_exp)
  local vgroup = gaptitudes[group]
  if vgroup ~= nil then
    vgroup[aptitude] = {title,init_exp,max_exp}
  end
end

function vRP.getAptitudeDefinition(group, aptitude)
  local vgroup = gaptitudes[group]
  if vgroup ~= nil and aptitude ~= "_title" then
    return vgroup[aptitude]
  else
    return nil
  end
end

function vRP.getAptitudeGroupTitle(group)
  if gaptitudes[group] ~= nil then
    return gaptitudes[group]._title
  else
    return ""
  end
end

-- return user aptitudes table
function vRP.getUserAptitudes(user_id)
  local data = vRP.getUserDataTable(user_id)
  if data ~= nil then
    if data.gaptitudes == nil then
      data.gaptitudes = {}
    end

    -- init missing aptitudes
    for k,v in pairs(gaptitudes) do
      if data.gaptitudes[k] == nil then -- init group
        data.gaptitudes[k] = {}
      end

      local group = data.gaptitudes[k]
      for l,w in pairs(v) do
        if l ~= "_title" and group[l] == nil then -- init aptitude exp
          group[l] = w[2] -- init exp
        end
      end
    end

    return data.gaptitudes
  else
    return nil
  end
end

function vRP.varyExp(user_id, group, aptitude, amount)
  local def = vRP.getAptitudeDefinition(group, aptitude)
  local uaptitudes = vRP.getUserAptitudes(user_id)
  if def ~= nil and uaptitudes ~= nil then
    -- apply variation
    local exp = uaptitudes[group][aptitude]
    local level = math.floor(vRP.expToLevel(exp)) -- save level before variation

    --- vary
    exp = exp+amount
    --- clamp
    if exp < 0 then exp = 0 
    elseif def[3] >= 0 and exp > def[3] then exp = def[3] end

    uaptitudes[group][aptitude] = exp

    -- info notify
    local player = vRP.getUserSource(user_id)
    if player ~= nil then
      local group_title = vRP.getAptitudeGroupTitle(group)
      local aptitude_title = def[1]

      --- exp
      if amount < 0 then        
        vRP.notify(player, locale('aptitude.lose_exp', group_title, aptitude_title, -1*amount), nil, 7000, 'inform')
      elseif amount > 0 then        
        vRP.notify(player, locale('aptitude.earn_exp', group_title, aptitude_title, amount), nil, 7000, 'inform')
      end
      --- level up/down
      local new_level = math.floor(vRP.expToLevel(exp))
      local diff = new_level-level
      if diff < 0 then
        vRP.notify(player, locale('aptitude.level_down', group_title, aptitude_title, new_level), nil, 7000, 'inform')        
      elseif diff > 0 then        
        vRP.notify(player, locale('aptitude.level_up', group_title, aptitude_title, new_level), nil, 7000, 'inform')
      end
      TriggerClientEvent('vRP:SetPlayerData', player, vRP.getPlayerInfo(user_id))
    end
  end
end

function vRP.levelUp(user_id, group, aptitude)
  local exp = vRP.getExp(user_id,group,aptitude)
  local next_level = math.floor(vRP.expToLevel(exp))+1
  local next_exp = vRP.levelToExp(next_level)
  local add_exp = next_exp-exp
  vRP.varyExp(user_id, group, aptitude, add_exp)
end

function vRP.levelDown(user_id, group, aptitude)
  local exp = vRP.getExp(user_id,group,aptitude)
  local prev_level = math.floor(vRP.expToLevel(exp))-1
  local prev_exp = vRP.levelToExp(prev_level)
  local add_exp = prev_exp-exp
  vRP.varyExp(user_id, group, aptitude, add_exp)
end

function vRP.getExp(user_id, group, aptitude)
  local uaptitudes = vRP.getUserAptitudes(user_id)
  if uaptitudes ~= nil then
    local vgroup = uaptitudes[group]
    if vgroup ~= nil then
      return vgroup[aptitude] or 0
    end
  end

  return 0
end

function vRP.setExp(user_id, group, aptitude, amount)
  local exp = vRP.getExp(user_id, group, aptitude)
  vRP.varyExp(user_id, group, aptitude, amount-exp)
end

-- return float
function vRP.expToLevel(exp)
  return math.floor((math.sqrt(1+8*exp/exp_step)-1)/2)
end

-- return integer
function vRP.levelToExp(lvl)
  return (exp_step*lvl*(lvl+1))/2
end

-- CONFIG

-- load config aptitudes
for k,v in pairs(cfg.gaptitudes) do
  vRP.defAptitudeGroup(k,v._title or "")
  for l,w in pairs(v) do
    if l ~= "_title" then
      vRP.defAptitude(k,l,w[1],w[2],w[3])
    end
  end
end
