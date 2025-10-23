# NOTE: None of these overlays change the default version of any package sets;
# For example, including `overlays.cudaPackages_11_4` will not set `cudaPackages_11` or `cudaPackages`;
# it only replaces `cudaPackages_11_4`.
let
  inherit (builtins) attrValues mapAttrs;

  gccOverlays =
    let
      mkGccVersionOverlay = name: final: _: {
        ${name} =
          final.lib.throwIf (!final ? gccVersions)
            "cuda-legacy.overlays.${name} requires cuda-legacy.overlays.gccVersions"
            final.gccVersions.${name};

        "${name}Stdenv" = final.overrideCC final.gccStdenv final.buildPackages.${name};
      };
    in
    # Attribute set which provides the top-level gccVersions attribute.
    {
      gccVersions = import ./gccVersions.nix;
    }
    # Overlays which require gccVersions overlay and expose a single gcc and gccStdenv at the top-level.
    // mapAttrs (name: _: mkGccVersionOverlay name) {
      gcc9 = null;
      gcc10 = null;
      gcc11 = null;
      gcc12 = null;
      gcc13 = null;
      gcc14 = null;
    };

  cudaOverlays =
    let
      mkCudaPackagesVersionOverlay = name: final: _: {
        ${name} =
          final.lib.throwIf (!final ? cudaPackagesVersions)
            "cuda-legacy.overlays.${name} requires cuda-legacy.overlays.cudaPackagesVersions"
            final.cudaPackagesVersions.${name};
      };
    in
    # Attribute set which updates _cuda and provides the top-level cudaPackagesVersions attribute.
    {
      cudaPackagesVersions = import ./cudaPackagesVersions.nix;
    }
    # Overlays which require cudaPackagesVersions overlay and expose a single versioned CUDA package set at
    # the top-level.
    // mapAttrs (name: _: mkCudaPackagesVersionOverlay name) {
      cudaPackages_11_4 = null;
      cudaPackages_11_5 = null;
      cudaPackages_11_6 = null;
      cudaPackages_11_7 = null;
      cudaPackages_11_8 = null;
      cudaPackages_12_0 = null;
      cudaPackages_12_1 = null;
      cudaPackages_12_2 = null;
      cudaPackages_12_3 = null;
      cudaPackages_12_4 = null;
      cudaPackages_12_5 = null;
      cudaPackages_12_6 = null;
      cudaPackages_12_8 = null;
      cudaPackages_12_9 = null;
      cudaPackages_13_0 = null;
    };
in
gccOverlays
// cudaOverlays
// {
  # default is the composition of all gccOverlays and cudaOverlays.
  # Our overlays commute so the order they are consumed does not matter; they are not, however, idempotent.
  default =
    final: prev:
    prev.lib.composeManyExtensions (attrValues gccOverlays ++ attrValues cudaOverlays) final prev;
}
