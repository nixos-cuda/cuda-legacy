# This overlay provides a number of GCC releases but does not introduce them into the top-level scope.
final: prev: {
  # Only include compilers which have been removed from upstream.
  gccVersions = final.callPackage ../pkgs/development/compilers/gcc/all.nix {
    # From https://github.com/NixOS/nixpkgs/blob/9296b9142eb6b016e441237ce433022f31364a83/pkgs/top-level/stage.nix#L72-L77
    # Non-GNU/Linux OSes are currently "impure" platforms, with their libc
    # outside of the store.  Thus, GCC, GFortran, & co. must always look for files
    # in standard system directories (/usr/include, etc.)
    noSysDirs =
      final.stdenv.buildPlatform.system != "x86_64-solaris"
      && final.stdenv.buildPlatform.system != "x86_64-kfreebsd-gnu";
  };
}
