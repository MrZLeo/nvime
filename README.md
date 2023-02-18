# 🦈 NVIME: Modern NeoVim Configuration

NVIME is a modern neovim configuration used **pure Lua**. It support Lsp feature, file exploer and many other feature.

There are two branches support two types of configuration.
- In **lsp** branch, we use pure Lua and builtin lsp support.
- In **master** branch, we use *coc* architecture and some vimscript is needed to use coc.

## Get Started

First you need to choose one configuration you like.

As far as I am concerned, *coc* is much mature, and it covers many good feature together with very good performance(start time of coc branch is near 60-80ms in my m1 macbook pro, *lsp* use **impatient** plugin will now can achieve this performance as well and even faster). While *lsp* use builtin lsp support, which is a new staff. It provides a easy way to use lsp and a better & active community to enhance the performance and functionality.

This is my suggestion:

- If you are a new user in vim/neovim, then choose *coc*, which is easy to install and use
- If you are familiar with vim/neovim and want to try new feature, then choose *lsp*

> ⚠️  *coc* branch is deprecated and no longer maintained. So try *lsp*.

### Coc Dependencies

These are dependencies that are needed for *coc*:

1. neovim

This is neovim support in pip, use pip3 to install it:
```bash
pip3 install neovim
```

2. Node.js

Use package manager to install it. For instance, in macOS, use `hoembrew`:

```
brew install node
```

### Commen Dependencies

These are dependencies that are needed both for *coc* and *lsp*.

In fedora, you need to install:

```bash
sudo dnf install \
    ripgrep \
    nodejs \
    tree-sitter-cli \
    gcc \
    g++ \
    unzip
```

other OS is the same.

### Clone project

> You must have neovim installed first

```
git clone --depth=1 https://github.com/MrZLeo/nvime ~/.config/nvim
```

And you can open neovim:

```
nvim
```

Then type command:

```
:PackerSync
```

When finished, exit and reopen your nvim:

```
:q
```

You will see some notifications from plugins. Don't worry about that. You can just follow what the notification says.

## Languages Support

For now, this configurations works for myself. So I am sure that it's nice for my development, mainly in **Rust**, often in **C/C++** and **Lua** is needed for this configuration. The system will download the LSP support automatically when you get whole project installed in your PC.

And you can check what you need

### *lsp*
```
:Mason
```

### *coc*
```bash
nvim ~/.config/nvim/config/plugins/coc.nvim.vim
```

and modify
```vim
let g:coc_global_extensions = [
    \ 'coc-vimlsp',
    \ 'coc-sh',
    \ 'coc-clangd',
    \ 'coc-lists',
    \ 'coc-word',
    \ 'coc-ci',
    \ 'coc-zi',
    \ 'coc-marketplace',
    \ 'coc-rust-analyzer',
    \ 'coc-json',
    \ 'coc-lua',
    \ 'coc-snippets'
  \ ]
```

