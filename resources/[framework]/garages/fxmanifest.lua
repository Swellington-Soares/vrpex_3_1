fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Swellington Soares'
description 'Allows players to store their vehicles in garages and withdraw job vehicles'
version '1.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

ui_page 'html/index.html'

files {
    'locales/*.json',
   'html/**'
}

dependencies {
    'ox_lib',
    'vrp'
}
