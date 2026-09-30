{
  description = "Neovim, language servers and formatting tools";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);

      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.buildEnv {
            name = "nvim-tools";

            paths = with pkgs; [
              neovim

              # Telescope search tools
              ripgrep
              fd

              # Language servers
              clang-tools
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

            pathsToLink = [
              "/bin"
              "/share"
            ];
          };
        }
      );
    };
}
