fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Swellington Soares'
version '1'

client_scripts {
		'config.lua',
    'client.lua'
}

ui_page 'dist/index.html'


files {
    'data/*.json',
    'dist/**',
}

escrow_ignore {
	'config.lua'
}
