fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'

game "gta5"

author "Xirvin & Project Sloth"
version '2.0.0'

lua54 'yes'


ui_page 'html/index.html'
-- ui_page 'http://localhost:3000/' --for dev

shared_script {
  '@ox_lib/init.lua',
  'shared/vrpex.lua',
  "shared/config.lua",
}

server_script {
  "server/**",
}

client_script {
  'client/**',
}

ox_lib {
  'locale',
  'cache',
  'zones',
  'interface'
}


files {
  'html/**',
  'locales/*.json'
}
