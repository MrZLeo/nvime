# Install editor tools only; Lua configuration and vim.pack remain unmanaged.
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    neovim

    # Telescope search tools
    ripgrep
    fd

    # Language servers
    llvmPackages_latest.clang-tools
    lua-language-server
    typescript
    ruff
    ty
    taplo
    texlab
    neocmakelsp
    nixd

    # Formatting and parser tooling
    nixfmt
    stylua
    tree-sitter
  ];
}
