fx_version 'cerulean'
game 'gta5'
lua54 'yes'
dependency '/assetpacks'
description 'm4-societycarshop'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'client.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}
