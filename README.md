# 🦈 NVIME: Modern NeoVim Configuration

NVIME is a modern neovim configuration used **pure Lua**. It support Lsp feature, file exploer and many other feature.

There are two branches support two types of configuration.
- In **lsp** branch, we use pure Lua and builtin lsp support.
- In **master** branch, we use *coc* architecture and some vimscript is needed to use coc.

## Get Started

> ⚠️  *coc* branch is deprecated and no longer maintained. So try *lsp*.

### !!! 🤩Archlinux installation scripts

if you are using arch linux, use `arch-install.sh` to help you install. Check the hints carefully.

if you are not, continue reading.

### Dependencies

These are dependencies that are needed both for *coc* and *lsp*.

In fedora, you need to install:

```bash
sudo dnf install \
    ripgrep \
    nodejs \
    tree-sitter-cli \
    gcc \
    g++ \
    wget \
    unzip
```

other OS is the same.


### Clone project

> You must have neovim installed first

```
git clone https://github.com/MrZLeo/nvime ~/.config/nvim
```

And you can open neovim:

```
nvim
```

installation will start automatically, when finished, exit and reopen your nvim:

```
:q
```

You will see some notifications from plugins. Don't worry about that. You can just follow what the notification says.

## Languages Support

For now, this configurations works for myself. So I am sure that it's nice for my development, mainly in **Rust**, often in **C/C++** and **Lua** is needed for this configuration. The system will download the LSP support automatically when you get whole project installed in your PC.

And you can check what you need

```
:Mason
```

