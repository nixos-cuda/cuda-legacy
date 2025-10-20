{ inputs, ... }:
{
  systems = [
    "aarch64-linux"
    "aarch64-darwin"
    "x86_64-linux"
    "x86_64-darwin"
  ];

  imports = [
    inputs.git-hooks-nix.flakeModule
    inputs.treefmt-nix.flakeModule
  ];

  perSystem =
    {
      config,
      pkgs,
      ...
    }:
    {
      pre-commit.settings.hooks = {
        # Formatter checks
        treefmt = {
          enable = true;
          package = config.treefmt.build.wrapper;
        };

        # Nix checks
        deadnix.enable = true;
        nil.enable = true;
        statix.enable = true;
      };

      treefmt = {
        projectRootFile = "flake.nix";
        programs = {
          # Markdown
          mdformat.enable = true;

          # Nix
          nixfmt = {
            enable = true;
            package = pkgs.nixfmt-rfc-style;
          };

          # Shell
          shellcheck.enable = true;
          shfmt.enable = true;
        };
      };
    };
}
