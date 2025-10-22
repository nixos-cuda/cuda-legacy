final: prev: {
  # Only include compilers which have been removed from upstream.
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
    gcc12
    ;

  gcc9Stdenv = final.overrideCC final.gccStdenv final.buildPackages.gcc9;
  gcc10Stdenv = final.overrideCC final.gccStdenv final.buildPackages.gcc10;
  gcc11Stdenv = final.overrideCC final.gccStdenv final.buildPackages.gcc11;
  gcc12Stdenv = final.overrideCC final.gccStdenv final.buildPackages.gcc12;

  # Only include cuda package sets which have been removed upstream.
  # Top-level fix-point used in `cudaPackages`' internals
  # NOTE: This differs from upstream in that we must pass `lib` explicitly because we do not have it in-tree.
  _cuda = import ./pkgs/development/cuda-modules/_cuda { inherit (final) lib; };

  inherit
    (import ./pkgs/top-level/cuda-packages.nix {
      inherit (final)
        _cuda
        callPackage
        config
        lib
        ;
    })
    cudaPackages_11_4
    cudaPackages_11_5
    cudaPackages_11_6
    cudaPackages_11_7
    cudaPackages_11_8
    cudaPackages_12_0
    cudaPackages_12_1
    cudaPackages_12_2
    cudaPackages_12_3
    cudaPackages_12_4
    cudaPackages_12_5
    cudaPackages_12_6
    cudaPackages_12_8
    cudaPackages_12_9
    cudaPackages_13_0
    ;

    cudaPackages_11 = final.lib.recurseIntoAttrs final.cudaPackages_11_8;
    cudaPackages_12 = final.lib.recurseIntoAttrs final.cudaPackages_12_9;
    cudaPackages_13 = final.lib.recurseIntoAttrs final.cudaPackages_13_0;
}
