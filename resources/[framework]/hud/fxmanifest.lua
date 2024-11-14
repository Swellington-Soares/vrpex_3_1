fx_version 'cerulean'
games { 'gta5' }
description "Forza Horizon 4 Speedometer"
ui_page "html/hud.html"
lua54 'yes'

files {
	"html/**"
}
shared_script {
	'@ox_lib/init.lua'
}
client_script "client.lua"
