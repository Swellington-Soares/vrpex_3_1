fx_version 'cerulean'
game 'gta5'
lua54 'yes'

description "RP module/framework"
ui_page "gui/index.html"

shared_scripts {
  '@ox_lib/init.lua',
  "lib/utils.lua",
  'cfg/**/*.lua',  
}
-- server scripts
server_scripts {
  '@oxmysql/lib/MySQL.lua', 
  "base.lua",
  'db_queries.lua',
  'modules/audio.lua',
  'modules/character.lua',
  "modules/gui.lua",
  "modules/group.lua",
  "modules/survival.lua",
  "modules/player_state.lua",
  "modules/map.lua",
  "modules/money.lua",
  "modules/inventory.lua",
  "modules/identity.lua",
  "modules/police.lua",
  "modules/aptitude.lua",
  "modules/basic_garage.lua",
  "modules/basic_items.lua",
  "modules/logging.lua",

  "lib/discord_embed.lua"
}

-- client scripts
client_scripts {
  "client/base.lua",
  'client/pedai.lua',
  'client/audio.lua',
  "client/gui.lua",
  "client/player_state.lua",
  "client/survival.lua",
  "client/map.lua",
  "client/identity.lua",
  "client/basic_garage.lua",
  "client/police.lua",
}

-- client files
files {
  "lib/Tunnel.lua",
  "lib/Proxy.lua",
  "lib/Debug.lua",
  "lib/Tools.lua",
}

dependencies  {
  'ox_lib',
  'oxmysql'
}

data_file 'FIVEM_LOVES_YOU_4B38E96CC036038F' 'events.meta'
data_file 'FIVEM_LOVES_YOU_341B23A2F0E0F131' 'popgroups.ymt'

files {
  'cfg/**/.lua',
  'ui/**',
  'locales/*.json',
  'events.meta',
  'popgroups.ymt',
  'relationships.dat',
  'sounds/**/*.ogg'
}
