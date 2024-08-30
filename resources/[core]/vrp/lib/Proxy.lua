-- Proxy interface system, used to add/call functions between resources

local Tools = module("lib/Tools")

local Proxy = {}
local rscname = GetCurrentResourceName()

local function proxy_resolve(itable, key)
  local mtable = getmetatable(itable)
  local iname = mtable.name
  local ids = mtable.ids
  local callbacks = mtable.callbacks
  local identifier = mtable.identifier

  local fname = key
  local no_wait = false
  if string.sub(key, 1, 1) == "_" then
    fname = string.sub(key, 2)
    no_wait = true
  end

  -- generate access function
  local fcall = function(...)
    local rid, r
    

    if no_wait then
      rid = -1
    else
      r = async()
      rid = ids:gen()
      callbacks[rid] = r
    end

    local args = { ... }

    TriggerEvent(iname .. ":proxy", fname, args, identifier, rid)

    if not no_wait then
      return r:wait()
    end
  end

  itable[key] = fcall -- add generated call to table (optimization)
  return fcall
end

--- Add event handler to call interface functions (can be called multiple times for the same interface name with different tables)
function Proxy.addInterface(name, itable)
  AddEventHandler(name .. ":proxy", function(member, args, identifier, rid)
    local f = itable[member]

    local rets = {}
    if type(f) == "function" then
      rets = { f(table.unpack(args, 1, table.maxn(args))) }
    else
      print("error: proxy call " .. name .. ":" .. member .. " not found")
    end

    if rid >= 0 then
      TriggerEvent(name .. ":" .. identifier .. ":proxy_res", rid, rets)
    end
  end)
end

-- get a proxy interface
-- name: interface name
-- identifier: unique string to identify this proxy interface access (if nil, will be the name of the resource)
function Proxy.getInterface(name, identifier)
  if not identifier then identifier = rscname end

  local ids = Tools.newIDGenerator()
  local callbacks = {}
  local r = setmetatable({},
    { __index = proxy_resolve, name = name, ids = ids, callbacks = callbacks, identifier = identifier })

  AddEventHandler(name .. ":" .. identifier .. ":proxy_res", function(rid, rets) 

    local callback = callbacks[rid]
    if callback then
      -- free request id
      ids:free(rid)
      callbacks[rid] = nil

      -- call
      callback(table.unpack(rets, 1, table.maxn(rets)))
    end
  end)

  return r
end

return Proxy
