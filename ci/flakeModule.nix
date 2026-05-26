{ inputs, ... }:
{
  systems = [
    "aarch64-linux"
    "x86_64-linux"
  ];

  perSystem =
    {
      pkgs,
      system,
      ...
    }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        config =
          { pkgs, ... }:
          {
            # By default, Nixpkgs allows aliases. Setting them to false allows us to detect breakages sooner rather
            # than later.
            allowAliases = false;
            allowUnfreePredicate = pkgs._cuda.lib.allowUnfreeCudaPredicate;
            cudaSupport = true;
          };
        localSystem = { inherit system; };
        overlays = [
          inputs.self.overlays.default
          # For CI or building from our flake, make our CUDA package sets top-level instead of upstream's ones.
          (_: prev: prev.cudaPackagesVersions)
        ];
      };

      legacyPackages = pkgs;
    };
}
