{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Doing this is equivalent to setting the nixpkgs input to self (so it brings it no dependencies), but allows us
    # to use `--override-input` because it *is* an input (which we cannot do without defining it).
    # In the creation of partitions below, we can compare inputs.nixpkgs.narHash against inputs.self.narHash and
    # conditionally forward explicitly provided Nixpkgs inputs and use a fallback if the NAR hashes match.
    nixpkgs.follows = "";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      # Required but can be empty -- this is set by the various sub-flake-modules.
      systems = [ ];

      imports = [
        inputs.flake-parts.flakeModules.partitions
      ];

      flake.overlays.default = import ./overlay.nix;

      partitionedAttrs = {
        checks = "dev";
        formatter = "dev";

        hydraJobs = "hydraJobs";

        legacyPackages = "legacyPackages";
      };

      partitions =
        let
          # Passing in Nixpkgs in this way allows us to provide the ability to override inputs
          # for sub-flakes while still keeping the entry-point to the flake very small.
          nixpkgs =
            if inputs.self.narHash == inputs.nixpkgs.narHash then
              # Fallback Nixpkgs
              builtins.getFlake "github:NixOS/nixpkgs/bf0d1707ba1e12471a0b554013187e0c5b74f779"
            else
              inputs.nixpkgs;
        in
        {
          # `dev` includes formatters and linters.
          # `dev` instantiates its own copy of Nixpkgs and does not use the one provided by
          # the `legacyPackages` partition.
          dev = {
            extraInputs = { inherit nixpkgs; };
            extraInputsFlake = ./dev;
            module = ./dev/flakeModule.nix;
          };

          # `hydraJobs` includes Hydra jobsets.
          # `hydraJobs` uses the copy of Nixpkgs configured by the `legacyPackages` partition.
          hydraJobs.module = ./hydraJobs/flakeModule.nix;

          # `legacyPackages` sets `_modules.args.pkgs` and exposes it as `legacyPackages`.
          # Partitions other than `dev` re-use the instance (or at least, the instantiation logic).
          legacyPackages = {
            extraInputs = { inherit nixpkgs; };
            module = ./legacyPackages/flakeModule.nix;
          };
        };
    };
}
