#! /usr/bin/bash

echo "This script will help you install dependencies and install plugins automatically

    - Firstly, make sure your neovim version >= 0.9
    - Password and sudo is required since we need to install packages
    - Feel free to follow the hints when neovim windows is opened
    - Use :q to exit nvim once everything finished

    "

# dependencies
if [ "$EUID" -ne 0 ] # if not root, use sudo
    then sudo pacman -S --needed python3 python-neovim nodejs ripgrep tree-sitter gcc wget unzip
    else pacman -S --needed python3 python-neovim nodejs ripgrep tree-sitter gcc wget unzip
fi

nvim # open and auto install plugins
