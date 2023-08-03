fx_version 'bodacious'
game 'gta5'

name 'climb-name'
author 'rlhys'
description 'climb copyright'

server_script {
    'server/server.lua',
    'version.lua',
    'config.lua'
}

client_scripts {
    'client/client.lua',
    'config.lua'
}

ui_page "html/index.html"

files {
    "html/index.html",
    "html/time.js"
}