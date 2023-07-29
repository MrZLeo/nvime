#! /bin/sh

echo "This script will help you install dependencies and install plugins automatically

    - Firstly, make sure your neovim version >= 0.9
    - Password and `sudo` is required since we need to install packages
    - Use `:q` to exit nvim once everything finished"

# dependencies
sudo pacman -S --needed python3 python-neovim nodejs ripgrep tree-sitter gcc 

nvim # open and auto install plugins
