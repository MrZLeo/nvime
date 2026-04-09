# 🦈 NVIME: Modern NeoVim Configuration

NVIME is a pure Lua Neovim configuration built around Neovim `0.12+`, the native `vim.pack` package manager, built-in LSP, and a compact plugin set.

## Snapshots

<img width="2032" alt="image" src="https://github.com/user-attachments/assets/4643a64a-f5ef-4ff7-baf6-fcab272275a7" />

<img width="2032" alt="image" src="https://github.com/user-attachments/assets/855301d8-63b4-415f-b57b-ef539f658b19" />

<img width="2032" alt="image" src="https://github.com/user-attachments/assets/c6f06f29-9764-46a2-b746-272f5da61f38" />

## Get Started

1. Install Neovim `0.12` or newer.
2. (Optional) On Arch Linux, run [arch-install.sh](arch-install.sh) to install common dependencies.
3. Otherwise, install the required tools manually:
   ```bash
   # Fedora example
   sudo dnf install \
       ripgrep \
       nodejs \
       tree-sitter-cli \
       gcc \
       g++ \
       wget \
       unzip
   ```
4. Clone this repository into your config path:
   ```bash
   git clone https://github.com/MrZLeo/nvime ~/.config/nvim
   ```
5. Start Neovim:
   ```bash
   nvim
   ```
   Missing plugins are installed automatically on first launch.

## Plugin Management

Plugin specs live in `plugin/*.lua` and are installed by `vim.pack`. Pinned revisions are stored in [nvim-pack-lock.json](nvim-pack-lock.json).

Example plugin spec:

```lua
vim.pack.add({
    {
        src = "https://github.com/user/repo",
        version = vim.version.range("*"),
    },
})
```

Useful maintenance commands:

- `:lua vim.pack.update()` updates plugins with a confirmation buffer.
- `:TSSyncParsers` installs or updates the Tree-sitter parsers listed in [plugin/02-treesitter.lua](plugin/02-treesitter.lua).

## Key Bindings

| Key Combination | Mode | Description |
|----------------|------|-------------|
| `<C-h/j/k/l>` | Normal | Navigate between windows |
| `<C-h/j/k/l>` | Terminal | Navigate between windows from terminal |
| `<C-w>k` | Normal | Split window above |
| `<C-w>h` | Normal | Split window left |
| `<C-w>j` | Normal | Split window below |
| `<C-w>l` | Normal | Split window right |
| `<BackSpace>` | Normal | Clear search highlighting |
| `<Space><Space>` | Normal | Save file |
| `-` | Normal | Open Oil file explorer |
| `<Leader>ff` | Normal | Find files |
| `<Leader>fg` | Normal | Live grep |
| `<Leader>fb` | Normal | List buffers |
| `<Leader>fh` | Normal | Help tags |
| `<Leader>o` | Normal | Toggle outline sidebar |
| `gD` | Normal | Go to declaration |
| `gd` | Normal | Go to definition (telescope) |
| `K` | Normal | Show hover information |
| `gi` | Normal | Go to implementation (telescope) |
| `gr` | Normal | Find references (telescope) |
| `<Space>rn` | Normal | Rename symbol |
| `<Space>f` | Normal | Code action |
| `<Space>l` | Normal | Show diagnostics (telescope) |

## Commands

- `:CodeCompanion` runs the inline assistant on the current buffer or selection.
- `:CodeCompanionChat Toggle` opens or hides the chat buffer.
- `:Outline` toggles the symbol outline window.
- `:Clear` deletes all hidden loaded buffers.
- `:Spell` toggles spell checking.
- `:TSSyncParsers` syncs the configured Tree-sitter parser set.

## LSP

LSP configuration is centralized in [plugin/zz-lsp.lua](plugin/zz-lsp.lua).

Current enabled servers:

```lua
local lsp_servers = {
    "clangd",
    "lua_ls",
    "ruff",
    "ty",
    "taplo",
    "texlab",
    "neocmake",
}
```

To add or remove a server, update that list and adjust any server-specific settings in the same file.

Current defaults include:

- Telescope-backed definition, implementation, reference, and diagnostics pickers
- Hover and floating diagnostics
- Inlay hints
- Format-on-save, except for filetypes explicitly skipped in [plugin/zz-lsp.lua](plugin/zz-lsp.lua)

## Notes

- CSV and TSV files auto-enable `csvview.nvim`.
- Tree-sitter highlighting starts on `FileType` when a parser is available.
- Generated theme artifacts under `after/` and local `nvim.log` are ignored by Git.
