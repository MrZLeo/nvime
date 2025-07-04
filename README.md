# 🦈 NVIME: Modern NeoVim Configuration

NVIME is a modern Neovim configuration using **pure Lua**. It leverages the built-in LSP features and improves startup times with [lazy.nvim](lua/plugins.lua). It also includes file exploration, syntax highlighting, inline hints, and more.

## Snapshots

<img width="2032" alt="image" src="https://github.com/user-attachments/assets/4643a64a-f5ef-4ff7-baf6-fcab272275a7" />

<img width="2032" alt="image" src="https://github.com/user-attachments/assets/855301d8-63b4-415f-b57b-ef539f658b19" />

<img width="2032" alt="image" src="https://github.com/user-attachments/assets/c6f06f29-9764-46a2-b746-272f5da61f38" />


## Get Started

1. Make sure your Neovim version ≥ 0.10.
2. (Optional) For Arch Linux, run [arch-install.sh](arch-install.sh) to install dependencies quickly.
3. Otherwise, install required packages manually:
   ```bash
   # Fedora as example
   sudo dnf install \
       ripgrep \
       nodejs \
       tree-sitter-cli \
       gcc \
       g++ \
       wget \
       unzip
   ```
4. Clone this repository into your Neovim config path:
   ```bash
   git clone https://github.com/MrZLeo/nvime ~/.config/nvim
   ```
5. Launch Neovim:
   ```bash
   nvim
   ```
   Installation starts automatically. Exit once done and reopen Neovim.

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
| `<Leader>ff` | Normal | Find files |
| `<Leader>fg` | Normal | Live grep |
| `<Leader>fb` | Normal | List buffers |
| `<Leader>fh` | Normal | Help tags |
| `gD` | Normal | Go to declaration |
| `gd` | Normal | Go to definition (telescope) |
| `K` | Normal | Show hover information |
| `gi` | Normal | Go to implementation (telescope) |
| `gr` | Normal | Find references (telescope) |
| `<Space>rn` | Normal | Rename symbol |
| `<Space>f` | Normal | Code action |
| `<Space>l` | Normal | Show diagnostics (telescope) |

## Language Server Protocol (LSP)

NVIME uses `nvim-lspconfig` for LSP support, with configurations organized in the `lua/lsp_config` directory:

### LSP Configuration Structure

- `lua/lsp_config/init.lua`: Main LSP initialization and auto-formatting setup
- `lua/lsp_config/on_attach.lua`: Keybindings and settings applied when LSP attaches to buffers
- `lua/lsp_config/diagnostic.lua`: Global diagnostic configurations (signs, virtual text, etc.)
- Language-specific configs:
  - `lua/lsp_config/rust.lua`: Rust LSP configuration via rustaceanvim
  - `lua/lsp_config/lsp/lua_ls.lua`: Lua LSP configuration
  - `lua/lsp_config/lsp/clangd.lua`: clangd LSP configuration

### Setting Up LSP

1. Install the required language servers:
   ```bash
   # Example installations:
   npm install -g lua-language-server   # Lua
   rustup component add rust-analyzer   # Rust
   sudo pacman -S clang                 # C/C++
   ```

2.  Add the server name to the `servers` list in `lua/lsp_config/init.lua`:
    ```lua
    -- lua/lsp_config/init.lua
    local lsp_server = {
        "clangd",
        "lua_ls",
        "ruff",
        "pyright",
        -- "ty",
        "taplo",
        "texlab",
        "neocmake",
    }
    ```

3. LSP features are automatically enabled when editing supported files. Common LSP commands:
   - `gd`: Go to definition (telescope)
   - `K`: Show hover information
   - `gi`: Go to implementation
   - See [Key Bindings](#key-bindings) for more

### Diagnostics and Visual Feedback

- Error/warning signs in the gutter
- Hover diagnostics (auto-show on cursor hold)
- Inlay hints for supported languages
- Automatic formatting on save (except for C/C++, you can change it in `lua/lsp/init.lua`)

LSP configurations can be customized by modifying the respective files in the `lua/lsp_config` directory.

That's it! Enjoy your updated Neovim setup.
