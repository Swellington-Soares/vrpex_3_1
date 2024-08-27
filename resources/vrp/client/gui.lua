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