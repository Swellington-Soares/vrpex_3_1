-- BLIPS: see https://wiki.gtanet.work/index.php?title=Blips for blip id/color

local Tools = module("vrp", "lib/Tools")
-- TUNNEL CLIENT API

-- BLIP

-- create new blip, return native id
function tvRP.addBlip(x, y, z, idtype, idcolor, text, size)
  local blip = AddBlipForCoord(x + 0.001, y + 0.001, z + 0.001) -- solve strange gta5 madness with integer -> double
  SetBlipSprite(blip, idtype)
  SetBlipAsShortRange(blip, true)
  SetBlipColour(blip, idcolor)
  SetBlipScale(blip, size)

  if text ~= nil then
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandSetBlipName(blip)
  end

  return blip
end

-- remove blip by native id
function tvRP.removeBlip(id)
  RemoveBlip(id)
end

local named_blips = {}

-- set a named blip (same as addBlip but for a unique name, add or update)
-- return native id
function tvRP.setNamedBlip(name, x, y, z, idtype, idcolor, text)
  tvRP.removeNamedBlip(name) -- remove old one

  named_blips[name] = tvRP.addBlip(x, y, z, idtype, idcolor, text)
  return named_blips[name]
end

-- remove a named blip
function tvRP.removeNamedBlip(name)
  if named_blips[name] ~= nil then
    tvRP.removeBlip(named_blips[name])
    named_blips[name] = nil
  end
end

-- GPS

-- set the GPS destination marker coordinates
function tvRP.setGPS(x, y)
  SetNewWaypoint(x + 0.0001, y + 0.0001)
end

-- set route to native blip id
function tvRP.setBlipRoute(id)
  SetBlipRoute(id, true)
end

-- MARKER

local markers = {}
local marker_ids = Tools.newIDGenerator()
local named_markers = {}

-- add a circular marker to the game map
-- return marker id
function tvRP.addMarker(
    markerId,
    x,
    y,
    z,
    sx,
    sy,
    sz, r, g, b, a, visible_distance, rx, ry, rz, updown, rotate,
    textureDict, textureName)
  local id = marker_ids:gen()
  local marker = lib.marker.new({
    coords = vec3(x + 0.001, y + 0.001, z + 0.001),
    type = markerId,
    bobUpAndDown = updown or false,
    rotate = rotate or false,
    color = { r = r or 0, g = g or 255, b = b or 255, a = a or 255 },
    height = sz,
    width = sx,
    textureDict = textureDict or nil,
    textureName = textureName or nil,
    rotation = vec3(rx or 0.0, ry or 0.0, rz or 0.0),
    faceCamera = false,
    distance = visible_distance or 20.0
  })
  markers[id] = marker

  return id
end

-- remove marker
function tvRP.removeMarker(id)
  if markers[id] then
    markers[id] = nil
    marker_ids:free(id)
  end
end

-- set a named marker (same as addMarker but for a unique name, add or update)
-- return id
function tvRP.setNamedMarker(name, markerId, x, y, z, sx, sy, sz, r, g, b, a, visible_distance, rx, ry, rz, updown,
                             rotate, textureDict, textureName)
  tvRP.removeNamedMarker(name) -- remove old marker

  named_markers[name] = tvRP.addMarker(markerId, x, y, z, sx, sy, sz, r, g, b, a, visible_distance, rx, ry, rz, updown,
    rotate, textureDict, textureName)
  return named_markers[name]
end

function tvRP.removeNamedMarker(name)
  if named_markers[name] then
    tvRP.removeMarker(named_markers[name])
    named_markers[name] = nil
  end
end

-- markers draw loop
Citizen.CreateThread(function()
  while true do
    local idle = 5000
    local pos = GetEntityCoords(PlayerPedId())
    for _, marker in pairs(markers) do
      if #(pos - marker.coords) <= (marker.distance or 15.0) then
        marker:draw()
        idle = 0
      end
    end
    Wait(idle)
  end
end)

-- AREA

local areas = {}

-- create/update a cylinder area ? esfera?
function tvRP.setArea(name, x, y, z, radius)
  local zone = lib.zones.sphere({
    coords = vec3(x + 0.001, y + 0.001, z + 0.001),
    radius = radius or 2.0
  })

  zone.onEnter = function(self)
    vRPserver._enterArea(name)
  end

  zone.onExit = function(self)
    vRPserver._leaveArea(name)
  end

  areas[name] = zone
end

-- remove area
function tvRP.removeArea(name)
  if areas[name] then
    areas[name]:remove()
    areas[name] = nil
  end
end
