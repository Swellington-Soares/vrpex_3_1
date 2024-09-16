fx_version 'cerulean'

game "gta5"

author "Project Sloth & OK1ez"
version '2.1.8'

lua54 'yes'

ui_page 'html/index.html'
-- ui_page 'http://localhost:5173/' --for dev

shared_script {
  '@ox_lib/init.lua',
  'shared/vrpex.lua',
  "shared/config.lua",
 
}

client_script {
  'client/**',
}

server_script {
  "server/**",
}


files {
  'html/**',
  'locales/*.json',
}

ox_lib {
  'locale',
  'require',
  'interface',
  'cache'
}

