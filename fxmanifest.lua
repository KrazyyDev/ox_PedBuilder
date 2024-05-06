fx_version('cerulean')
games({ 'gta5' })
lua54('yes')
author('krazyy13')
description 'OX PED BUILDER'

shared_scripts({
    '@ox_lib/init.lua',
    'shared/config.lua',
});

server_scripts({
    'server/main.lua',
});

client_scripts({
    'client/main.lua',
});

files({
    'locales/*.json',
    'peds.json'
});

-- Position du ped
-- Model
-- Freeze
-- Invincible
-- Animation
-- Animation dict