final: prev: {
  gcc9Stdenv = final.overrideCC final.gccStdenv final.buildPackages.gcc9;
  gcc10Stdenv = final.overrideCC final.gccStdenv final.buildPackages.gcc10;
  gcc11Stdenv = final.overrideCC final.gccStdenv final.buildPackages.gcc11;

  inherit
    (final.callPackage ./pkgs/development/compilers/gcc/all.nix {
      # From https://github.com/NixOS/nixpkgs/blob/9296b9142eb6b016e441237ce433022f31364a83/pkgs/top-level/stage.nix#L72-L77
      # Non-GNU/Linux OSes are currently "impure" platforms, with their libc
      # outside of the store.  Thus, GCC, GFortran, & co. must always look for files
      # in standard system directories (/usr/include, etc.)
      noSysDirs =
        final.stdenv.buildPlatform.system != "x86_64-solaris"
        && final.stdenv.buildPlatform.system != "x86_64-kfreebsd-gnu";
    })
    gcc9
    gcc10
    gcc11
    ;

  cudaPackages_11_0 = final.callPackage ./pkgs/top-level/cuda-packages.nix { cudaVersion = "11.0"; };
  cudaPackages_11_1 = final.callPackage ./pkgs/top-level/cuda-packages.nix { cudaVersion = "11.1"; };
  cudaPackages_11_2 = final.callPackage ./pkgs/top-level/cuda-packages.nix { cudaVersion = "11.2"; };
  cudaPackages_11_3 = final.callPackage ./pkgs/top-level/cuda-packages.nix { cudaVersion = "11.3"; };
  cudaPackages_11_4 = final.callPackage ./pkgs/top-level/cuda-packages.nix { cudaVersion = "11.4"; };
  cudaPackages_11_5 = final.callPackage ./pkgs/top-level/cuda-packages.nix { cudaVersion = "11.5"; };
  cudaPackages_11_6 = final.callPackage ./pkgs/top-level/cuda-packages.nix { cudaVersion = "11.6"; };
  cudaPackages_11_7 = final.callPackage ./pkgs/top-level/cuda-packages.nix { cudaVersion = "11.7"; };
  cudaPackages_11_8 = final.callPackage ./pkgs/top-level/cuda-packages.nix { cudaVersion = "11.8"; };
  cudaPackages_11 = final.lib.recurseIntoAttrs final.cudaPackages_11_8;

  cudatoolkit_11 = final.cudaPackages_11.cudatoolkit;
}
