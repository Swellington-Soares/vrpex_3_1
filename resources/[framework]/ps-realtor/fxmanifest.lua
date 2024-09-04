fx_version 'cerulean'

game "gta5"

author "Xirvin & Project Sloth"
version '0.0.6'

lua54 'yes'


ui_page 'html/index.html'
-- ui_page 'http://localhost:3000/' --for dev

shared_script {
  '@ox_lib/init.lua',
  '@vrp/lib/utils.lua',
  "shared/**",
}

server_script {
  "server/**",
}

client_script {
  'client/**',
}


files {
  'html/**',
}
