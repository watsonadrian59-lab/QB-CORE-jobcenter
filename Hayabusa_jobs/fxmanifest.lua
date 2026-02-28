fx_version 'cerulean'
game 'gta5'

name 'Hayabusa-Jobs'
description 'Modern City Job Application UI'
author 'Hayabusa'
version '2.0.0'

ui_page 'html/index.html'

shared_script 'config.lua'

client_script 'client.lua'
server_script 'server.lua'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

dependencies {
    'qb-core',
    'qb-target'
}