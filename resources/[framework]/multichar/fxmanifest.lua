fx_version 'cerulean'
game 'gta5'
author 'Swellington Soares'
version '1'
lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    '@vrp/lib/utils.lua',
    'config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}


client_scripts {
    -- 'client/zoomtext.lua',
    -- 'client/intro.lua',
    'client/main.lua',
}

files {
    'locales/*.json',
    'assets/deleted.jpg'
}

ox_lib {
    'locale',
    'cache'
}

dependencies {
    'ox_lib',
    'vrp',
    'sw_appearance',
}
