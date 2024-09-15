fx_version 'cerulean'
game 'gta5'
author 'Swellington Soares'
version '1'
lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'shared.lua'
}

server_scripts {
    's_main.lua'
}

client_scripts {
    'c_main.lua',
}

files {
    'locales/*.json'
}

ox_lib {
    'locale'
}

dependencies {
    'ox_lib',
    'vrp',
    'ox_inventory',
    'ox_target'
}
