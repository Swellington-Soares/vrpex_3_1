fx_version 'cerulean'
game 'gta5'

author 'okok#3488'
description 'okokBanking'
lua54 'yes'

ui_page 'web/ui.html'

files {
	'web/*.*'
}

shared_script {
	'@ox_lib/init.lua',
	'shared/config.lua',
	'shared/vrpex.lua'
}

client_scripts {
	'client.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server.lua'
}

ox_lib {
	'locale'
}

