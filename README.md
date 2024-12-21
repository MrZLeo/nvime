# 🦈 NVIME: Modern NeoVim Configuration

NVIME is a modern Neovim configuration using **pure Lua**. It leverages the built-in LSP features and improves startup times with [lazy.nvim](lua/plugins.lua). It also includes file exploration, syntax highlighting, inline hints, and more.

## Get Started

1. Make sure your Neovim version ≥ 0.9.
2. (Optional) For Arch Linux, run [arch-install.sh](arch-install.sh) to install dependencies quickly.
3. Otherwise, install required packages manually:
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
| `q` | Normal/Visual | Close current window |
| `Q` | Normal | Record macro (replaces default 'q') |
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

NVIME uses `nvim-lspconfig` for LSP support, with configurations organized in the `lua/lsp` directory:

### LSP Configuration Structure

- `lua/lsp/init.lua`: Main LSP initialization and auto-formatting setup
- `lua/lsp/on_attach.lua`: Keybindings and settings applied when LSP attaches to buffers
- `lua/lsp/settings.lua`: Global diagnostic configurations (signs, virtual text, etc.)
- Language-specific configs:
  - `lua/lsp/lua.lua`: Lua LSP configuration
  - `lua/lsp/rust.lua`: Rust LSP configuration via rustaceanvim
  - `lua/lsp/clangd.lua`: C/C++ LSP configuration with inlay hints

### Setting Up LSP

1. Install the required language servers:
   ```bash
   # Example installations:
   npm install -g lua-language-server    # Lua
   rustup component add rust-analyzer    # Rust
   sudo pacman -S clang                 # C/C++
   ```

2. LSP servers are configured in `lua/plugins.lua` under the `nvim-lspconfig` plugin. To add a new LSP:
   ```lua
   {
       'neovim/nvim-lspconfig',
       opts = {
           servers = {
               -- Add your LSP config here
               new_language_server = {
                   -- server-specific settings
               }
           }
       }
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

LSP configurations can be customized by modifying the respective files in the `lua/lsp` directory.
That's it! Enjoy your updated Neovim setup.
