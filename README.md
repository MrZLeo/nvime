# 🦈 NVIME: Modern NeoVim Configuration

NVIME is a pure Lua Neovim configuration built around Neovim `0.12+`, the native `vim.pack` package manager, built-in LSP, and a compact plugin set.

## Snapshots

<img width="2032" alt="image" src="https://github.com/user-attachments/assets/4643a64a-f5ef-4ff7-baf6-fcab272275a7" />

<img width="2032" alt="image" src="https://github.com/user-attachments/assets/855301d8-63b4-415f-b57b-ef539f658b19" />

<img width="2032" alt="image" src="https://github.com/user-attachments/assets/c6f06f29-9764-46a2-b746-272f5da61f38" />

## Install from Source

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

## Install from Release Bundle

Tagged releases publish prebuilt bundles for both Linux and macOS:

- Linux: `.tar.gz`
- macOS: `.dmg`

Each bundle contains:

- `install.sh`: installs the packaged config and downloaded plugins
- `payload/config/nvim`: the NVIME config
- `payload/data/nvim/site/pack/core/opt`: the bootstrapped `vim.pack` plugin directory

Installation defaults:

- Config: `${XDG_CONFIG_HOME:-$HOME/.config}/nvim`
- Data: `${XDG_DATA_HOME:-$HOME/.local/share}/nvim`

To install a release bundle:

1. Download the matching release artifact for your platform.
2. Extract or open it.
3. Run the installer:
   ```bash
   ./install.sh
   ```
4. Start Neovim:
   ```bash
   nvim
   ```

The installer creates timestamped backups before replacing an existing install.
It also checks that `nvim` is already installed and that the detected version is
`0.12` or newer.

Useful installer options:

- `./install.sh --config-dir /path/to/nvim`
- `./install.sh --data-dir /path/to/share/nvim`
- `./install.sh --no-backup`

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

## Release CI

GitHub Actions builds and publishes release artifacts for tags matching `v*.*.*.*`.

Release tags follow this format:

- `v<neovim-major>.<neovim-minor>.<neovim-patch>.<nvime-revision>`
- Example: `v0.12.1.0`

The first three fields track the upstream Neovim version. The final field is the
NVIME release revision for that upstream version and starts at `0`.

The release pipeline does three things:

1. Runs a headless smoke test on `ubuntu-latest` and `macos-latest`.
2. Builds platform-native bundles after the smoke test passes.
3. Publishes the generated packages to the GitHub Release for that tag.

The workflow can be triggered in two ways:

1. Manually push a tag such as `v0.12.1.0`.
2. Let the monthly scheduled run check `master`; on the first day of each month
   at `00:00 UTC`, if there are commits since the previous release tag, it
   creates the next tag automatically and publishes a release from that commit.

Example release flow:

```bash
git tag v0.12.1.0
git push origin v0.12.1.0
```

Local helper scripts used by CI:

- [scripts/ci-prepare-release.sh](scripts/ci-prepare-release.sh): resolves the release version and creates scheduled tags
- [scripts/ci-smoke.sh](scripts/ci-smoke.sh): headless startup validation
- [scripts/ci-install-nvim.sh](scripts/ci-install-nvim.sh): installs Neovim in CI
- [scripts/ci-package.sh](scripts/ci-package.sh): bootstraps plugins and builds release bundles
- [scripts/install-bundle.sh](scripts/install-bundle.sh): installs a packaged release locally

