{
  # These are stub inputs. We provide defaults for them in the definition of outputs.
  #
  # Declaring inputs as `inputs.<name>,follows = "";` is equivalent to setting the input to self (so it brings it no
  # dependencies), but allows us to use `--override-input` because it *is* an input (which we cannot do without
  # defining it).
  #
  # In the creation of partitions below, we compare `inputs.<name>.narHash` against `inputs.self.narHash` and
  # conditionally forward explicitly provided inputs, using a default if the NAR hashes of the two match (indicating
  # the absence of an override).
  inputs = {
    flake-parts.follows = "";
    nixpkgs.follows = "";
  };

  outputs =
    _inputs:
    let
      inputs =
        let
          defaults = {
            nixpkgs = builtins.getFlake "github:NixOS/nixpkgs/bf0d1707ba1e12471a0b554013187e0c5b74f779";
            flake-parts = builtins.getFlake "github:hercules-ci/flake-parts/864599284fc7c0ba6357ed89ed5e2cd5040f0c04";
          };

          # If processing self or an input distinct from self, pass it through.
          # Otherwise, we have a stub input and should use its default.
          inputOrDefault =
            self: name: value:
            if name == "self" || self.narHash != value.narHash then value else defaults.${name};
        in
        builtins.mapAttrs (inputOrDefault _inputs.self) _inputs;

      overlays.default = import ./overlay.nix;

      flake = inputs.flake-parts.lib.mkFlake { inherit inputs; } {
        # Required but can be empty -- this is set by the various sub-flake-modules.
        systems = [ ];

        imports = [
          inputs.flake-parts.flakeModules.partitions
        ];

        flake = {
          inherit overlays;
        };

        partitionedAttrs = {
          checks = "dev";
          formatter = "dev";

          hydraJobs = "hydraJobs";

          legacyPackages = "legacyPackages";
        };

        partitions = {
          # `dev` includes formatters and linters.
          # `dev` instantiates its own copy of Nixpkgs and does not use the one provided by
          # the `legacyPackages` partition.
          dev = {
            extraInputs = { inherit (inputs) nixpkgs; };
            extraInputsFlake = ./dev;
            module = ./dev/flakeModule.nix;
          };

          # `hydraJobs` includes Hydra jobsets.
          # `hydraJobs` uses the copy of Nixpkgs configured by the `legacyPackages` partition.
          hydraJobs.module = ./hydraJobs/flakeModule.nix;

          # `legacyPackages` sets `_modules.args.pkgs` and exposes it as `legacyPackages`.
          # Partitions other than `dev` re-use the instance (or at least, the instantiation logic).
          legacyPackages = {
            extraInputs = { inherit (inputs) nixpkgs; };
            module = ./legacyPackages/flakeModule.nix;
          };
        };
      };
    in
    {
      inherit overlays;
      inherit (flake)
        checks
        formatter
        hydraJobs
        legacyPackages
        ;
    };
}
