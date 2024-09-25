fx_version 'cerulean'
game 'gta5'
author 'Swellington Soares'
version '1'
lua54 'yes'

nui_callback_strict_mode 'true'

shared_scripts {
    '@ox_lib/init.lua',    
    'config.lua',
    'vrpex.lua'
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

ox_lib {
    'locale',
    'cache',
    'zones'
}

dependencies  {
    'ox_lib',
    'vrp',
    'sw_appearance',
    'ox_target'
  }
