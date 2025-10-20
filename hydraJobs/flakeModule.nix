{
  systems = [
    "aarch64-linux"
    "x86_64-linux"
  ];

  transposition.hydraJobs.adHoc = true;

  perSystem =
    { lib, pkgs, ... }:
    {
      hydraJobs = import ./. { inherit lib pkgs; };
    };
}
