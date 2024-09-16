fx_version 'cerulean'
game 'gta5'
lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',   
    'shared/config.lua',
    'shared/vrpex.lua'
}

server_scripts {
    'server/main.lua'
}

client_scripts{
    'client/main.lua'
}

files {
    'locales/*.json'
}

ox_lib {
    'locale',
    'cache'
}
