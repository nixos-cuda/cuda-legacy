{ inputs, ... }:
{
  systems = [
    "aarch64-linux"
    "x86_64-linux"
  ];

  transposition.hydraJobs.adHoc = true;

  perSystem =
    {
      lib,
      pkgs,
      system,
      ...
    }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        config =
          { pkgs }:
          {
            allowUnfreePredicate = pkgs._cuda.lib.allowUnfreeCudaPredicate;
            cudaSupport = true;
          };
        localSystem = { inherit system; };
        overlays = [ inputs.self.overlays.default ];
      };

      hydraJobs = import ./hydraJobs.nix { inherit lib pkgs; };

      legacyPackages = pkgs;
    };
}
