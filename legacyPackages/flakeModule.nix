{ inputs, ... }:
{
  systems = [
    "aarch64-linux"
    "x86_64-linux"
  ];

  perSystem =
    { pkgs, system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        config = {
          allowUnfree = true;
          cudaSupport = true;
        };
        localSystem = { inherit system; };
        overlays = [ inputs.self.overlays.default ];
      };

      legacyPackages = pkgs;
    };
}
