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

  # NOTE: As a consequence of pushing down use of the flake-parts input, but must stick to builtins in constructing
  # `outputs` instead of using flake-parts.inputs.nixpkgs-lib.lib.
  outputs =
    _inputs:
    let
      inherit (builtins) getFlake mapAttrs;

      inputs =
        let
          defaults = {
            nixpkgs = getFlake "github:NixOS/nixpkgs/c4efd683cf02958ebb2111603de84abe3f89de3f";
            flake-parts = getFlake "github:hercules-ci/flake-parts/0010412d62a25d959151790968765a70c436598b";
          };

          # If processing self or an input distinct from self, pass it through.
          # Otherwise, we have a stub input and should use its default.
          inputOrDefault =
            self: name: value:
            if name == "self" || self.narHash != value.narHash then value else defaults.${name};
        in
        mapAttrs (inputOrDefault _inputs.self) _inputs;

      # NOTE: None of these overlays change the default version of any package sets;
      # For example, including `overlays.cudaPackages_11_4` will not set `cudaPackages_11` or `cudaPackages`;
      # it only replaces `cudaPackages_11_4`.
      overlays.default = import ./overlays;

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

          legacyPackages = "ci";
        };

        partitions = {
          # `dev` includes formatters and linters.
          dev = {
            extraInputs = { inherit (inputs) nixpkgs; };
            extraInputsFlake = ./dev;
            module = ./dev/flakeModule.nix;
          };

          # `ci` sets `_modules.args.pkgs`, exposes it as `legacyPackages`.
          ci = {
            extraInputs = { inherit (inputs) nixpkgs; };
            module = ./ci/flakeModule.nix;
          };
        };
      };
    in
    {
      inherit inputs overlays;
      inherit (flake)
        checks
        formatter
        legacyPackages
        ;
    };
}
