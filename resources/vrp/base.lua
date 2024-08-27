local blockCfg = require('@vrp.cfg.block') or {}
local Proxy = module("lib/Proxy")
local Tunnel = module("lib/Tunnel")
Debug = module("lib/Debug")

lib.locale()

local config = module("cfg/base")

vRP = {}
Proxy.addInterface("vRP", vRP)

tvRP = {}
Tunnel.bindInterface("vRP", tvRP) -- listening for client tunnel

-- init
vRPclient = Tunnel.getInterface("vRP") -- server -> client tunnel

vRP.users = {}                         -- will store logged users (id) by first identifier
vRP.rusers = {}                        -- store the opposite of users
vRP.user_tables = {}                   -- user data tables (logger storage, saved to database)
vRP.user_tmp_tables = {}               -- user tmp data tables (logger storage, not saved)
vRP.user_sources = {}                  -- user sources

local prepared_queries = {}

function vRP.prepare(name, query)
  if not query then return end
  prepared_queries[name] = query
end

function vRP.query(name, params)
  if not prepared_queries[name] then
    error('Query [' .. name .. '] not found.', 1)
  end
  return MySQL.query.await(prepared_queries[name], params)
end

function vRP.execute(name, params)
  if not prepared_queries[name] then
    error('Query [' .. name .. '] not found.', 1)
  end
  return MySQL.rawExecute.await(prepared_queries[name], params)
end

function vRP.scalar(name, params)
  if not prepared_queries[name] then
    error('Query [' .. name .. '] not found.', 1)
  end
  return MySQL.scalar.await(prepared_queries[name], params)
end

function vRP.insert(name, params)
  if not prepared_queries[name] then
    error('Query [' .. name .. '] not found.', 1)
  end
  return MySQL.insert.await(prepared_queries[name], params)
end

function vRP.single(name, params)
  if not prepared_queries[name] then
    error('Query [' .. name .. '] not found.', 1)
  end
  return MySQL.single.await(prepared_queries[name], params)
end

function vRP.update(name, params)
  if not prepared_queries[name] then
    error('Query [' .. name .. '] not found.', 1)
  end
  return MySQL.update.await(prepared_queries[name], params)
end

-- identification system

--- sql.
-- return user id or nil in case of error (if not found, will create it)
function vRP.getUserByIdentifier(identifier)
  return vRP.single('vRP/getUser', { identifier })
end

--internal vrp only
local function CreateNewUser(license, discord, fivemId)
  return vRP.insert('vRP/create_user', { license, discord, fivemId })
end

function vRP.getPlayerEndpoint(player)
  return GetPlayerEndpoint(player) or '0.0.0.0'
end

function vRP.getPlayerName(player)
  return GetPlayerName(player) or "unknown"
end

--- sql
function vRP.isBanned(user_id)
  return vRP.single('vRP/getUserBanned', { user_id }) ~= nil
end

--- sql
function vRP.setBanned(user_id, banned, reason)
  if banned then
    reason = reason or 'Banido por não seguir as regras'
    vRP.update("vRP/setUserBanned", { user_id, reason })
  else
    vRP.update('vRP/removeUserBan', { user_id })
  end
end

--- sql
function vRP.isAllowed(user_id)
  return vRP.scalar("vRP/isUserAllowed", { user_id })
end

--- sql
function vRP.setAllowed(user_id, allow)
  allow = allow and 1 or 0
  return vRP.update("vRP/setUserAllowed", { allow, user_id })
end

function vRP.setUData(user_id, key, value)
  if type(key) ~= "string" then error('Key need be a string', 1) end
  if type(value) == "table" then value = json.encode(value) end
  vRP.execute("vRP/setUData", { user_id, key, value })
end

function vRP.getUData(user_id, key)
  if type(key) ~= "string" then error('Key need be a string', 1) end
  return vRP.scalar('vRP/getUData', { user_id, key }) or nil
end

function vRP.setSData(key, value)
  if type(key) ~= "string" then error('Key need be a string', 1) end
  if type(value) == "table" then value = json.encode(value) end
  vRP.execute("vRP/setServerData", { key, value })
end

function vRP.getSData(key)
  if type(key) ~= "string" then error('Key need be a string', 1) end
  return vRP.scalar('vRP/getServerData', { key }) or nil
end

function vRP.setPlayerData(player_id, key, value)
  if type(key) ~= "string" then error('Key need be a string', 1) end
  if type(value) == "table" then value = json.encode(value) end
  vRP.execute("vRP/setPlayerData", { player_id, key, value })
end

function vRP.getPlayerData(player_id, key)
  if type(key) ~= "string" then error('Key need be a string', 1) end
  return vRP.scalar('vRP/getPlayerData', { player_id, key }) or nil
end

-- return user data table for vRP internal persistant connected user storage

function vRP.getPlayerTable(user_id)
  return vRP.user_tables[user_id]
end

function vRP.getUserDataTable(user_id)
  return vRP.user_tables[user_id]?.datatable
end

function vRP.getUserTmpTable(user_id)
  return vRP.user_tmp_tables[user_id]
end

-- return the player spawn count (0 = not spawned, 1 = first spawn, ...)
function vRP.getSpawns(user_id)
  local tmp = vRP.getUserTmpTable(user_id)
  if tmp then
    return tmp.spawns or 0
  end

  return 0
end

function vRP.getUserId(source)
  if source ~= nil and source ~= 0 then
    local license = vRP.getPlayerIdentifier(source, 'license')
    return vRP.users[license]
  end
  return nil
end

-- return map of user_id -> player source
function vRP.getUsers()
  local users = {}
  for k, v in pairs(vRP.user_sources) do
    users[k] = v
  end

  return users
end

-- return source or nil
function vRP.getUserSource(user_id)
  return vRP.user_sources[user_id]
end

function vRP.ban(source, reason)
  local user_id = vRP.getUserId(source)

  if user_id then
    vRP.setBanned(user_id, true)
    vRP.kick(source, "[Banned] " .. reason)
  end
end

function vRP.kick(source, reason)
  DropPlayer(source, reason)
end

-- drop vRP player/user (internal usage)
function vRP.dropPlayer(source)
  print(source)
  vRPclient._removePlayer(-1, source)

  local user_id = vRP.getUserId(source)
  if user_id then
    TriggerEvent("vRP:playerLeave", user_id, source)
    vRP.save(user_id, '__INTERNAL__')
    vRP.users[vRP.rusers[user_id]] = nil
    vRP.rusers[user_id] = nil
    vRP.user_tables[user_id] = nil
    vRP.user_tmp_tables[user_id] = nil
    vRP.user_sources[user_id] = nil
  end
end

CreateThread(function()
  while true do
    for k in next, vRP.user_tables or {} do
      vRP.save(k, '__INTERNAL__')
    end
    Wait(60000)
  end
end)

-- -- tasks

-- function task_save_datatables()
--   SetTimeout(config.save_interval * 1000, task_save_datatables)
--   TriggerEvent("vRP:save")

--   Debug.log("save datatables")
--   for k, v in pairs(vRP.user_tables) do
--     vRP.setUData(k, "vRP:datatable", json.encode(v))
--   end
-- end

-- async(function()
--   task_save_datatables()
-- end)

-- -- ping timeout
-- function task_timeout()
--   local users = vRP.getUsers()
--   for k, v in pairs(users) do
--     if GetPlayerPing(v) <= 0 then
--       vRP.kick(v, "[vRP] Ping timeout.")
--       vRP.dropPlayer(v)
--     end
--   end

--   SetTimeout(30000, task_timeout)
-- end

-- task_timeout()

-- handlers
function vRP.getPlayerIdentifier(source, xtype)
  return GetPlayerIdentifierByType(source, xtype or "license")
end

local function deffer_uppdate(d, m)
  d.update(m)
  Wait(1000)
end

AddEventHandler("playerConnecting", function(name, setMessage, deferrals)
  local source = source
  lib.print.info(source)
  local license = vRP.getPlayerIdentifier(source, 'license')

  deferrals.defer()

  Wait(0)

  if not license then
    return deferrals.done(locale('license_not_found'))
  end

  deffer_uppdate(deferrals, locale('conn_check_self'))

  local user = vRP.getUserByIdentifier(license)

  if not user then
    local discord = vRP.getPlayerIdentifier(source, 'discord')

    if not discord then
      return deferrals.done(locale('discord_id_not_found'))
    end

    local fivemId = vRP.getPlayerIdentifier(source, 'fivem')
    if not fivemId then
      return deferrals.done(locale('fivem_id_not_found'))
    end

    local userId = CreateNewUser(license, discord, fivemId)
    if not userId then
      return deferrals.done(locale('user_created_error'))
    end

    return deferrals.done(locale('user_created', userId, GetConvar('vrp:discord', 'DISCORD LINK NOT FOUND')))
  end

  deffer_uppdate(deferrals, locale('conn_check_allowed'))

  if config.enable_allowlist and not user.allowed then
    return deferrals.done(locale('user_not_allowed', user.id, GetConvar('vrp:discord', 'DISCORD LINK NOT FOUND')))
  end

  deffer_uppdate(deferrals, locale('conn_check_banned'))

  local isBanned, reason = vRP.isBanned(user.id)

  if isBanned then
    return deferrals.done(locale('user_as_banned', reason, user.id))
  end

  if vRP.rusers[user.id] then
    DropPlayer(vRP.user_tables[user.id], locale('user_already_connected'))
    return deferrals.done(locale('user_already_connected'))
  end

  vRP.users[license] = user.id
  vRP.rusers[user.id] = license
  vRP.user_tables[user.id] = {}
  vRP.user_sources[user.id] = source
  vRP.user_tmp_tables[user.id] = { spawns = 0 }

  Wait(0)
  deferrals.done()
end)

AddEventHandler("playerDropped", function(reason)
  local source = source
  Debug.log("playerDropped " .. source)
  vRP.dropPlayer(source)
end)


AddEventHandler('playerJoining', function(_)
  local source  = source
  local user_id = vRP.getUserId(source)
  if not user_id then
    DropPlayer(source, locale('login_failed'))
    return CancelEvent()
  end
  vRP.user_sources[user_id] = source
  local spawns = (vRP.user_tmp_tables[user_id]?.spawns or 0)
  local first_spawn = spawns == 1
  vRP.user_tmp_tables[user_id].spawns = vRP.user_tmp_tables[user_id].spawns + 1
  if first_spawn then
    for _, v in next, vRP.user_sources or {} do
      vRPclient._addPlayer(source, v)
    end
    vRPclient._addPlayer(-1, source)
    TriggerEvent("vRP:playerJoin", source, user_id, first_spawn)
  end
  lib.print.info('playerJoining', source)
end)


RegisterCommand('testfw', function()
  local license = 'license:89f2de13f3dc0b2a5bf991021d7fa5c8370f4afe'
  local user_id = 1
  vRP.users[license] = user_id
  vRP.rusers[user_id] = license
  vRP.user_sources[user_id] = source
  local user = MySQL.single.await("SELECT * FROM players WHERE id = ?", { user_id })
  if not user then return end
  user.datatable = json.decode(user?.datatable or '{}')
  user.inventory = json.decode(user?.inventory or '[]')
  user.money = json.decode(user?.money or '{"cash": 0, "bank": 1000}')
  vRP.user_tables[user_id] = user
  vRP.addUserGroup(user_id, 'police', 1)
end)

RegisterCommand('re', function(source)
  local license = GetPlayerIdentifierByType(source, "license")
  local user = vRP.getUserByIdentifier(license)
  local user_id = user.id
  vRP.users[license] = user_id
  vRP.rusers[user_id] = license
  vRP.user_sources[user_id] = source
end)


RegisterCommand('vt', function(source, args, raw)
  print(json.encode(vRP.user_tables))
  print(json.encode(vRP.rusers))
  print(json.encode(vRP.user_sources))
end)

RegisterCommand('ex', function(source, args, raw)
  local code = raw
  local x, err = load("return " .. code:sub(3), '', "bt", _G)
  if not x then
    print('ERROR', err)
    return
  end

  local _, result = pcall(x)
  print('RESULT', result)
end)


RegisterCommand("addgroup", function(source, args, raw)
  local user_id = 1
end)


-- --onesync event
AddEventHandler('entityCreating', function(handle)
  local _type = GetEntityType(handle)
  local model = GetEntityModel(handle)
  if (_type == 1 and blockCfg.peds[model]) or
      (_type == 2 and blockCfg.vehicles[model]) then
    CancelEvent()
  end
end)
