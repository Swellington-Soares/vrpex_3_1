-- PROMPT
function tvRP.prompt(title, default_text)
  local input = lib.inputDialog(title,
    {
      { type = 'input', label = '', description = '', default = default_text, required = false, min = 0, max = 150 },
    })
  local result = input and input[1] or ""
  vRPserver._promptResult(result)
end

-- REQUEST

function tvRP.request(id, text, time)
  local alert = lib.alertDialog({
    header = '',
    content = text,
    cancel = true,
    centered = true,
    size = 'md',
  })

  print(alert)

  vRPserver._requestResult(id, alert == 'confirm')
end

function tvRP.announce(background, content)
  SendNUIMessage({ act = "announce", background = background, content = content })
end

-- init
RegisterNUICallback("init", function(data, cb)   -- NUI initialized
  SendNUIMessage({ act = "cfg", cfg = cfg.gui }) -- send cfg
  TriggerEvent("vRP:NUIready")
end)

-- PROGRESS BAR

-- -- create/update a progress bar
-- function tvRP.setProgressBar(name,anchor,text,r,g,b,value)
--   local pbar = {name=name,anchor=anchor,text=text,r=r,g=g,b=b,value=value}

--   -- default values
--   if pbar.value == nil then pbar.value = 0 end

--   SendNUIMessage({act="set_pbar",pbar = pbar})
-- end

-- -- set progress bar value in percent
-- function tvRP.setProgressBarValue(name,value)
--   SendNUIMessage({act="set_pbar_val", name = name, value = value})
-- end

-- -- set progress bar text
-- function tvRP.setProgressBarText(name,text)
--   SendNUIMessage({act="set_pbar_text", name = name, text = text})
-- end

-- -- remove a progress bar
-- function tvRP.removeProgressBar(name)
--   SendNUIMessage({act="remove_pbar", name = name})
-- end

-- -- DIV

-- -- set a div
-- -- css: plain global css, the div class is "div_name"
-- -- content: html content of the div
-- function tvRP.setDiv(name,css,content)
--   SendNUIMessage({act="set_div", name = name, css = css, content = content})
-- end

-- -- set the div css
-- function tvRP.setDivCss(name,css)
--   SendNUIMessage({act="set_div_css", name = name, css = css})
-- end

-- -- set the div content
-- function tvRP.setDivContent(name,content)
--   SendNUIMessage({act="set_div_content", name = name, content = content})
-- end

-- -- execute js for the div
-- -- js variables: this is the div
-- function tvRP.divExecuteJS(name,js)
--   SendNUIMessage({act="div_execjs", name = name, js = js})
-- end

-- -- remove the div
-- function tvRP.removeDiv(name)
--   SendNUIMessage({act="remove_div", name = name})
-- end

-- -- AUDIO

-- -- play audio source (once)
-- --- url: valid audio HTML url (ex: .ogg/.wav/direct ogg-stream url)
-- --- volume: 0-1
-- --- x,y,z: position (omit for unspatialized)
-- --- max_dist  (omit for unspatialized)
-- function tvRP.playAudioSource(url, volume, x, y, z, max_dist)
--   SendNUIMessage({act="play_audio_source", url = url, x = x, y = y, z = z, volume = volume, max_dist = max_dist})
-- end

-- -- set named audio source (looping)
-- --- name: source name
-- --- url: valid audio HTML url (ex: .ogg/.wav/direct ogg-stream url)
-- --- volume: 0-1
-- --- x,y,z: position (omit for unspatialized)
-- --- max_dist  (omit for unspatialized)
-- function tvRP.setAudioSource(name, url, volume, x, y, z, max_dist)
--   SendNUIMessage({act="set_audio_source", name = name, url = url, x = x, y = y, z = z, volume = volume, max_dist = max_dist})
-- end

-- -- remove named audio source
-- function tvRP.removeAudioSource(name)
--   SendNUIMessage({act="remove_audio_source", name = name})
-- end

-- local listener_wait = math.ceil(1/cfg.audio_listener_rate*1000)

-- Citizen.CreateThread(function()
--   while true do
--     Citizen.Wait(listener_wait)


--     local x,y,z
--     if cfg.audio_listener_on_player then
--       local ped = GetPlayerPed(PlayerId())
--       x,y,z = table.unpack(GetPedBoneCoords(ped, 31086, 0,0,0)) -- head pos
--     else
--       x,y,z = table.unpack(GetGameplayCamCoord())
--     end

--     local fx,fy,fz = tvRP.getCamDirection()
--     SendNUIMessage({act="audio_listener", x = x, y = y, z = z, fx = fx, fy = fy, fz = fz})
--   end
-- end)





-- -- detect players near, give positions to AudioEngine
-- Citizen.CreateThread(function()
--   local n = 0
--   local ns = math.ceil(cfg.voip_interval/listener_wait) -- connect/disconnect every x milliseconds

--   while true do
--     Citizen.Wait(listener_wait)

--     n = n+1
--     local voip_check = (n >= ns)
--     if voip_check then n = 0 end

--     local pid = PlayerId()
--     local spid = GetPlayerServerId(pid)
--     local px,py,pz = tvRP.getPosition()

--     local positions = {}

--     local players = tvRP.getPlayers()
--     for k,v in pairs(players) do
--       local player = GetPlayerFromServerId(k)

--       if player ~= pid and NetworkIsPlayerConnected(player) then
--         local oped = GetPlayerPed(player)
--         local x,y,z = table.unpack(GetPedBoneCoords(oped, 31086, 0,0,0)) -- head pos
--         positions[k] = {x,y,z} -- add position

--         if cfg.vrp_voip and voip_check then -- vRP voip detection/connection
--           local distance = GetDistanceBetweenCoords(x,y,z,px,py,pz,true)
--           local in_radius = (distance <= cfg.voip_proximity)
--           local linked = tvRP.isVoiceConnected("world", k)
--           local initiator = (spid < k)
--           if in_radius and not linked and initiator then -- join radius
--             tvRP.connectVoice("world", k)
--           elseif not in_radius and linked then -- leave radius
--             tvRP.disconnectVoice("world", k)
--           end
--         end
--       end
--     end

--     positions._ = true -- prevent JS array type
--     SendNUIMessage({act="set_player_positions", positions=positions})
--   end
-- end)

-- CONTROLS/GUI
