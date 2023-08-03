fx_version 'cerulean'
game 'gta5'
author 'rhys'
description 'climb'
lua54 'yes'
dependency "climb"

shared_scripts {
    'configs/locales.lua',
    'configs/config.lua'
}

client_scripts{ 
    'lib/Tunnel.lua',
    'lib/Proxy.lua',
    'client/client.lua'
}

server_scripts {
    '@climb/lib/utils.lua',
    'configs/server_customise_me.lua',
    'server/*.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/*.css',
    'html/js/*.js',
    'html/font/*.svg',
    'html/font/*.ttf',
    'html/font/*.eot',
    'html/font/*.woff',
    'html/font/*.woff2',
    'html/images/**/*.svg',
    'html/sound/*.ogg'
}

exports {
    'GetWeather'
}

server_exports {
    'GetWeather'
}

provide 'vSync'
