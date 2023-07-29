#! /usr/bin/bash

echo "This script will help you install dependencies and install plugins automatically

    - Firstly, make sure your neovim version >= 0.9
    - Password and sudo is required since we need to install packages
    - Use :q to exit nvim once everything finished

    "

# dependencies
if (whoami != root)
    then sudo pacman -S --needed python3 python-neovim nodejs ripgrep tree-sitter gcc
    else pacman -S --needed python3 python-neovim nodejs ripgrep tree-sitter gcc
fi

nvim # open and auto install plugins
