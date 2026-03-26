# This overlay provides a number of GCC releases but does not introduce them into the top-level scope.
final: prev:
let
  # We cannot use final.lib to construct the attribute set (we would get infinite recursion) given ./auto.nix
  # adding values to top-level.
  genAttrs' = names: f: builtins.listToAttrs (map f names);

  # Ensure gccVersions is safe to iterate over by import-ing to avoid callPackage-added values.
  # Additionally, import-ing allows us to specify the attributes we need explicitly, avoiding
  # infinite recursion in ./auto.nix, as we would otherwise not know the attribute names of
  # gccVersions if they depended on top-level.
  gccVersions = import ../pkgs/development/compilers/gcc/all.nix {
    inherit (final)
      buildPackages
      callPackage
      isl_0_20
      lib
      overrideCC
      pkgs
      stdenv
      targetPackages
      wrapCC
      ;

    # From https://github.com/NixOS/nixpkgs/blob/9296b9142eb6b016e441237ce433022f31364a83/pkgs/top-level/stage.nix#L72-L77
    # Non-GNU/Linux OSes are currently "impure" platforms, with their libc
    # outside of the store.  Thus, GCC, GFortran, & co. must always look for files
    # in standard system directories (/usr/include, etc.)
    noSysDirs =
      final.stdenv.buildPlatform.system != "x86_64-solaris"
      && final.stdenv.buildPlatform.system != "x86_64-kfreebsd-gnu";
  };
in
{
  inherit gccVersions;

  gccStdenvVersions = genAttrs' (builtins.attrNames gccVersions) (name: {
    name = name + "Stdenv";
    value = final.overrideCC final.gccStdenv final.buildPackages.gccVersions.${name};
  });
}
