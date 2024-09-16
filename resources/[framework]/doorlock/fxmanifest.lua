fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Swellington Soares'
description 'Door management system allowing players to lock and unlock doors port of qb-core doorlock by kakarot'
version '2.0.0'

ui_page 'html/index.html'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'configs/*.lua',  
    'vrpex.lua',
}

server_script 'server/main.lua'
client_script 'client/main.lua'

ox_lib {
    'locale',
    'cache'
}


files {
    'html/*.html',
    'html/*.js',
    'html/*.css',
    'html/sounds/*.ogg',
    'locales/*.json'
}
