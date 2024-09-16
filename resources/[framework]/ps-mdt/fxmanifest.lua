fx_version 'cerulean'
game 'gta5'

author 'Flawws, Flakey, Idris and the Project Sloth team and Su\'el'
description 'EchoRP MDT Rewrite for QBCore'
version '2.7.2'

lua54 'yes'

shared_script {
    '@ox_lib/init.lua',
    'shared/vrpex.lua', 
    'shared/config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/utils.lua',
    'server/dbm.lua',
    'server/main.lua'
}
client_scripts{
    'client/main.lua',
    'client/cl_impound.lua',
    'client/cl_mugshot.lua'
} 

ui_page 'ui/dashboard.html'

files {
    'ui/img/*.png',
    'ui/img/*.webp',
    'ui/img/*.jpg',
    'ui/dashboard.html',
    'ui/app.js',
    'ui/style.css',
}

ox_lib {
    'locale',
    'cache'
}

files {
    'locales/*.json'
}
