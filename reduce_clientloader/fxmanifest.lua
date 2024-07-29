-- shared_script '@reduce_clientloader/resource/shared.lua'

game 'gta5'
fx_version 'cerulean'

lua54 'yes'
reduce_clientloader 'yes'
use_experimental_fxv2_oal 'yes'

author 'https://reduce-security.net/'


shared_script 'resource/shared.lua'

server_scripts {
    'resource/server/functions.lua',
    'resource/server/main.lua'
}