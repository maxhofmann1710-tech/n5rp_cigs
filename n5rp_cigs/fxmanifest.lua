fx_version 'cerulean'
game 'gta5'

author 'N5RP'
description 'Smoking - Cigarette - System / NikotinBar / NikotinFlash / Throw Animation / BETA 1.1'
version '1.1.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
    -- other shared scripts
}

client_scripts {
    -- other client scripts
    'client/*.lua', -- ADD THIS LINE (adjust path if different)
}

server_scripts {
    -- other server scripts
    'server/*.lua', -- ADD THIS LINE (adjust path if different)
}

lua54 'yes'