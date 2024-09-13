-- this module describe the group/permission system

-- group functions are used on connected players only
-- multiple groups can be set to the same player, but the gtype config option can be used to set some groups as unique

-- api

local cfg = module("cfg/groups")
local groups = cfg.groups or {}
local xusers = cfg.users or {}

function vRP.getGroups()
  return groups
end

function vRP.getGroupGradeInfo(group, gradeNameOrRank)
  if not groups[group]?._config?.grades then return nil end
  local isRank = tonumber(gradeNameOrRank) ~= nil
  for k, grade in next, groups[group]?._config?.grades do
    if (isRank and k == gradeNameOrRank) or string.lower(grade.name) == string.lower(gradeNameOrRank) then
      local _data = table.clone(grade)
      _data['rank'] = k
      _data['group'] = group
      return _data
    end
  end
  return nil
end

function vRP.getGroupMaxGrade(group)
  return groups[group]?._config?.grades and #groups[group]?._config?.grades or 0
end

-- return group title
function vRP.getGroupTitle(group)
  local g = groups[group]

  return g?._config?.title or ""
end

function vRP.getGroupData(group)
  return groups[group]
end

-- get groups keys of a connected user
function vRP.getUserGroups(user_id)
  local data = vRP.getUserDataTable(user_id)
  if data then
    if data.groups == nil then
      data.groups = {} -- init groups
    end

    return data.groups
  else
    return {}
  end
end

-- add a group to a connected user
function vRP.addUserGroup(user_id, group, grade)
  if not vRP.hasGroup(user_id, group, grade) then
    local user_groups = vRP.getUserGroups(user_id)
    local ngroup = groups[group]
    if ngroup then
      if ngroup._config and ngroup._config.gtype ~= nil then
        -- copy group list to prevent iteration while removing
        local _user_groups = {}
        for k, v in pairs(user_groups) do
          _user_groups[k] = v
        end

        for k, v in pairs(_user_groups) do -- remove all groups with the same gtype
          local kgroup = groups[k]
          if kgroup and kgroup._config and ngroup._config and kgroup._config.gtype == ngroup._config.gtype then
            vRP.removeUserGroup(user_id, k)
          end
        end
      end

      -- add group
      user_groups[group] = { rank = grade or 0 }
      if ngroup._config.gtype == 'job' then
        user_groups[group]['duty'] = true
      end

      local player = vRP.getUserSource(user_id)
      if ngroup._config and ngroup._config.onjoin and player ~= nil then
        ngroup._config.onjoin(player) -- call join callback
      end

      -- trigger join event
      local gtype = nil
      if ngroup._config then
        gtype = ngroup._config.gtype
      end

      local rank = user_groups[group]?.rank or 0
      local rankName = rank > 0 and ngroup[group]?._config?.grades[rank] or ""
      local jobType = ngroup[group]?._config?.jobType or ""

      TriggerEvent("vRP:playerJoinGroup", {
        user_id = user_id,
        group = group,
        gtype = gtype,
        rank = rank,
        rankName = rankName,
        jobType = jobType,
        onduty = user_groups[group]['duty']
      })

      if player then
        TriggerClientEvent("vRP:updateGroupInfo", player, {
          name = group, --fix compat
          group = group,
          gtype = gtype,
          jobType = jobType,
          rankName = rankName,
          rank = rank,
          isboss = ngroup[group]?._config?.grades[rank]?.isboss,
          duty = user_groups[group]['duty'],
          action = 'enter'
        })
        TriggerClientEvent('vRP:SetPlayerData', player, vRP.getPlayerInfo(user_id))
      end
    end
  end
end

-- remove a group from a connected user
function vRP.removeUserGroup(user_id, group)
  local user_groups = vRP.getUserGroups(user_id)
  local groupdef = groups[group]
  if groupdef and groupdef._config and groupdef._config.onleave then
    local source = vRP.getUserSource(user_id)
    if source then
      groupdef._config.onleave(source) -- call leave callback
    end
  end

  -- trigger leave event
  local gtype = nil
  if groupdef._config then
    gtype = groupdef._config.gtype
  end

  local rank = user_groups[group]?.rank or 0
  local rankName = rank > 0 and groupdef[group]?._config?.grades[rank] or ""
  local jobType = groupdef[group]?._config?.jobType or ""

  TriggerEvent("vRP:playerLeaveGroup", {
    user_id = user_id,
    group = group,
    gtype = gtype,
    rank = rank,
    rankName = rankName,
    jobType = jobType,
    onduty = user_groups[group]['duty']
  })

  local player = vRP.getUserSource(user_id)
  if player then
    TriggerClientEvent("vRP:updateGroupInfo", player, {
      name = group,
      group = group,
      gtype = gtype,
      jobType = jobType,
      rankName = rankName,
      rank = rank,
      isboss = groupdef[group]?._config?.grades[rank]?.isboss,
      duty = user_groups[group]['duty'],
      action = 'leave'
    })
    TriggerClientEvent('vRP:SetPlayerData', player, vRP.getPlayerInfo(user_id))
  end    
  user_groups[group] = nil
end

-- get user group by type
-- return group name or an empty string
function vRP.getUserGroupByType(user_id, gtype)
  local user_groups = vRP.getUserGroups(user_id)
  for k, v in pairs(user_groups) do
    local kgroup = groups[k]
    if kgroup then
      if kgroup._config and kgroup._config.gtype and kgroup._config.gtype == gtype then
        return k, v, kgroup
      end
    end
  end

  return nil
end

-- return list of connected users by group
function vRP.getUsersByGroup(group)
  local users = {}

  for k, v in pairs(vRP.rusers) do
    if vRP.hasGroup(tonumber(k), group) then users[#users + 1] = tonumber(k) end
  end

  return users
end

-- return list of connected users by permission
function vRP.getUsersByPermission(perm)
  local users = {}

  for k, v in pairs(vRP.rusers) do
    if vRP.hasPermission(tonumber(k), perm) then
      users[#users + 1] = tonumber(k)
    end
  end

  return users
end



-- check if the user has a specific group
function vRP.hasGroup(user_id, group, grade)
  local user_groups = vRP.getUserGroups(user_id)
  if not grade or grade == 0 then
    return (user_groups[group] ~= nil)
  end
  return user_groups?[group]?.grade == grade
end

local func_perms = {}

-- register a special permission function
-- name: name of the permission -> "!name.[...]"
-- callback(user_id, parts)
--- parts: parts (strings) of the permissions, ex "!name.param1.param2" -> ["name", "param1", "param2"]
--- should return true or false/nil
function vRP.registerPermissionFunction(name, callback)
  func_perms[name] = callback
end

--[[
  vRP.hasPermission(user_id, '!grade.police.>.major')
  vRP.hasPermission(user_id, '!grade.police.>.1')
]]
vRP.registerPermissionFunction('grade', function(user_id, parts)
  local group = parts[2]
  local op = #parts == 4 and parts[3] or "="
  local grade = #parts == 4 and parts[4] or parts[3]

  local gradeInfo = vRP.getGroupGradeInfo(group, grade)

  if not gradeInfo then return false end
  local user_groups = vRP.getUserGroups(user_id)

  if user_groups[group] then
    if op == '=' then
      return (user_groups[group]?.rank or 0) == (gradeInfo.rank or 0)
    end

    if op == "!=" then
      return (user_groups[group]?.rank or 0) ~= (gradeInfo.rank or 0)
    end

    if op == '>' then
      return (user_groups[group]?.rank or 0) > (gradeInfo.rank or 0)
    end

    if op == '<' then
      return (user_groups[group]?.rank or 0) < (gradeInfo.rank or 0)
    end

    if op == '>=' then
      return (user_groups[group]?.rank or 0) >= (gradeInfo.rank or 0)
    end

    if op == '<=' then
      return (user_groups[group]?.rank or 0) <= (gradeInfo.rank or 0)
    end
  end

  return false
end)

-- register not fperm (negate another fperm)
vRP.registerPermissionFunction("not", function(user_id, parts)
  return not vRP.hasPermission(user_id, "!" .. table.concat(parts, ".", 2))
end)

vRP.registerPermissionFunction("is", function(user_id, parts)
  local param = parts[2]
  if param == "inside" then
    local player = vRP.getUserSource(user_id)
    if player then
      return vRPclient.isInside(player)
    end
  elseif param == "invehicle" then
    local player = vRP.getUserSource(user_id)
    if player then
      return vRPclient.isInVehicle(player)
    end
  end
end)

--helper functions

function vRP.hasGroupWithGrade(user_id, group, grade)
  return vRP.hasPermission(user_id, "!grade." .. group .. "." .. grade)
end

function vRP.hasGroupWithGradeGreater(user_id, group, grade)
  return vRP.hasPermission(user_id, "!grade." .. group .. ".>." .. grade)
end

function vRP.hasGroupWithGradeSmaller(user_id, group, grade)
  return vRP.hasPermission(user_id, "!grade." .. group .. ".<." .. grade)
end

function vRP.hasGroupWithGradeGreaterOrEqual(user_id, group, grade)
  return vRP.hasPermission(user_id, "!grade." .. group .. ".>=." .. grade)
end

function vRP.hasGroupWithGradeSmallOrEqual(user_id, group, grade)
  return vRP.hasPermission(user_id, "!grade." .. group .. ".<=." .. grade)
end

function vRP.hasGroupNotInGrade(user_id, group, grade)
  return vRP.hasPermission(user_id, "!grade." .. group .. ".!=." .. grade)
end

-- check if the user has a specific permission
function vRP.hasPermission(user_id, perm)
  local user_groups = vRP.getUserGroups(user_id)

  local fchar = string.sub(perm, 1, 1)

  if fchar == "@" then -- special aptitude permission
    local _perm = string.sub(perm, 2, string.len(perm))
    local parts = splitString(_perm, ".")
    if #parts == 3 then -- decompose group.aptitude.operator
      local group = parts[1]
      local aptitude = parts[2]
      local op = parts[3]

      local alvl = math.floor(vRP.expToLevel(vRP.getExp(user_id, group, aptitude)))

      local fop = string.sub(op, 1, 1)
      if fop == "<" then -- less (group.aptitude.<x)
        local lvl = parseInt(string.sub(op, 2, string.len(op)))
        if alvl < lvl then return true end
      elseif fop == ">" then -- greater (group.aptitude.>x)
        local lvl = parseInt(string.sub(op, 2, string.len(op)))
        if alvl > lvl then return true end
      else -- equal (group.aptitude.x)
        local lvl = parseInt(string.sub(op, 1, string.len(op)))
        if alvl == lvl then return true end
      end
    end
  elseif fchar == "#" then -- special item permission
    local _perm = string.sub(perm, 2, string.len(perm))
    local parts = splitString(_perm, ".")
    if #parts == 2 then -- decompose item.operator
      local item = parts[1]
      local op = parts[2]

      local amount = vRP.getInventoryItemAmount(user_id, item)

      local fop = string.sub(op, 1, 1)
      if fop == "<" then -- less (item.<x)
        local n = parseInt(string.sub(op, 2, string.len(op)))
        if amount < n then return true end
      elseif fop == ">" then -- greater (item.>x)
        local n = parseInt(string.sub(op, 2, string.len(op)))
        if amount > n then return true end
      else -- equal (item.x)
        local n = parseInt(string.sub(op, 1, string.len(op)))
        if amount == n then return true end
      end
    end
  elseif fchar == "!" then -- special function permission
    local _perm = string.sub(perm, 2, string.len(perm))
    local parts = splitString(_perm, ".")
    if #parts > 0 then
      local fperm = func_perms[parts[1]]
      if fperm then
        return fperm(user_id, parts) or false
      else
        return false
      end
    end
  else -- regular plain permission
    -- precheck negative permission
    local nperm = "-" .. perm
    for k, v in pairs(user_groups) do
      if v then -- prevent issues with deleted entry
        local group = groups[k]
        if group then
          for l, w in pairs(group) do -- for each group permission
            if l ~= "_config" and w == nperm then return false end
          end
        end
      end
    end

    -- check if the permission exists
    for k, v in pairs(user_groups) do
      if v then -- prevent issues with deleted entry
        local group = groups[k]
        if group then
          for l, w in pairs(group) do -- for each group permission
            if l ~= "_config" and w == perm then return true end
          end
        end
      end
    end
  end

  return false
end

-- check if the user has a specific list of permissions (all of them)
function vRP.hasPermissions(user_id, perms)
  for k, v in pairs(perms) do
    if not vRP.hasPermission(user_id, v) then
      return false
    end
  end

  return true
end

function vRP.userGroupPromote(user_id, group)
  if not groups[group]?._config?.grades or not vRP.hasGroup(user_id, group) then return false end
  local max = vRP.getGroupMaxGrade(group)
  local user_groups = vRP.getUserGroups(user_id)
  if user_groups?[group]?.rank < max then
    user_groups[group].rank = user_groups[group].rank + 1
    local src = vRP.getUserSource(user_id)
    if src then
      TriggerClientEvent("vRP:updateGroupRank", src, { group = group, rank = user_groups[group].rank })
      TriggerClientEvent('vRP:SetPlayerData', src, vRP.getPlayerInfo(user_id))
    end
    return true
  end

  return false
end

function vRP.userGroupDemote(user_id, group)
  if not groups[group]?._config?.grades or not vRP.hasGroup(user_id, group) then return false end
  local user_groups = vRP.getUserGroups(user_id)
  if user_groups?[group]?.rank > 1 then
    user_groups[group].rank = user_groups[group].rank - 1
    local src = vRP.getUserSource(user_id)
    if src then
      TriggerClientEvent("vRP:updateGroupRank", src, { group = group, rank = user_groups[group].rank })
      TriggerClientEvent('vRP:SetPlayerData', src, vRP.getPlayerInfo(user_id))
    end
    return true
  end

  return false
end

function vRP.isGroupGradeBoss(group, grade)
  grade = tonumber(grade)
  local rankInfo = groups[group]?._config?.grades[grade]
  return rankInfo and (grade >= groups[group]?._config?.grades or rankInfo?.isboss)
end

AddEventHandler('vrp:login', function(source, user_id, char_id, first_spawn)
  if first_spawn then
    local user = xusers[char_id]
    if user then
      for k, v in next, user do
        vRP.addUserGroup(user_id, v.name, v.rank or 0)
      end

      vRP.addUserGroup(user_id, 'user', 0)
    end
  end

  local user_groups = vRP.getUserGroups(user_id)
  for k in next, user_groups or {} do
    local group = groups[k]
    TriggerClientEvent("vRP:updateGroupInfo", source, {
      group = group,
      type = groups[k]?._config?.gtype,
      rank = user_groups[group]?.rank or 0,
      duty = user_groups[group]?.duty or false,
      action = 'enter'
    })
    if group?._config?.onspawn then
      group._config.onspawn(source)
    end
  end
end)
