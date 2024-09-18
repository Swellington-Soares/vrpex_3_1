fx_version "cerulean"
game "gta5"
lua54 'yes'

ui_page "dist/index.html"

shared_scripts {
	'@ox_lib/init.lua'
}

client_scripts {	
	"client/client.lua"
}

files {
	"dist/**"
}              