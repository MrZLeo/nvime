let g:startify_padding_left = 10
let g:startify_custom_header = [
\'              ███▄    █ ██▒   █▓ ██▓ ███▄ ▄███▓▓█████ ',
\'              ██ ▀█   █▓██░   █▒▓██▒▓██▒▀█▀ ██▒▓█   ▀ ',
\'             ▓██  ▀█ ██▒▓██  █▒░▒██▒▓██    ▓██░▒███   ',
\'             ▓██▒  ▐▌██▒ ▒██ █░░░██░▒██    ▒██ ▒▓█  ▄ ',
\'             ▒██░   ▓██░  ▒▀█░  ░██░▒██▒   ░██▒░▒████▒',
\'             ░ ▒░   ▒ ▒   ░ ▐░  ░▓  ░ ▒░   ░  ░░░ ▒░ ░',
\'             ░ ░░   ░ ▒░  ░ ░░   ▒ ░░  ░      ░ ░ ░  ░',
\'                ░   ░ ░     ░░   ▒ ░░      ░      ░   ',
\'                      ░      ░   ░         ░      ░  ░',
\'                       ░                         ',
\]

let g:startify_files_number = 6

" command 命令
let g:startify_commands = [
    \ {'u': ['Update Plugin', 'PlugUpdate']},
    \ {'s': ['Start Time', 'StartupTime']},
    \ ]

let g:startify_lists = [
       \ { 'type': 'files',     'header': ['        Most recent use']            },
       \ { 'type': 'commands',  'header': ['        Commands']       },
       \ ]

