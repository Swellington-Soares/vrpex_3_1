fx_version 'cerulean'
game "gta5"
author "Xirvin#0985 and Project Sloth"
version '1.2.2'
repository 'Project-Sloth/ps-housing'
lua54 'yes'
ui_page 'html/index.html'

dependencies {
  'fivem-freecam',
  'ps_housing_assets',
}

shared_script {
  '@ox_lib/init.lua',
  '@vrp/lib/utils.lua',
  "shared/config.lua",
  "shared/framework.lua",
}

client_script {
  'client/shell.lua',
  'client/apartment.lua',
  'client/cl_property.lua',
  'client/client.lua',
  'client/modeler.lua',
  'client/migrate.lua'
}

server_script {
  '@oxmysql/lib/MySQL.lua',
  "server/sv_property.lua",
  "server/server.lua",  
}

data_file 'TIMECYCLEMOD_FILE' 'tm.xml'

files {
  'html/**',
  'tm.xml',
  'locales/*.json'
}
