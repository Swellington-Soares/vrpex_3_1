fx_version 'cerulean'
game 'gta5'
author 'Swellington Soares'
version '1'
lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',    
    'config.lua'
}

server_scripts {
    'server/main.lua'
}


client_scripts {
    'client/main.lua',    
}

files {
    'locales/*.json'
}


dependencies  {
    'ox_lib',
    'vrp',
    'sw_appearance',
    'ox_target'
  }