{
  # The name of the redistributable for which to evaluate all combinations.
  redistName,

  # The platforms supported by the NixOS-CUDA Hydra instance
  supportedSystems ? [
    "x86_64-linux"
    "aarch64-linux"
  ],

  # The system evaluating this expression
  evalSystem ? builtins.currentSystem or "x86_64-linux",

  # Specific CUDA capabilities to set.
  cudaCapabilities ? null,

  # The path to Nixpkgs -- resolved inputs are made available in outputs.
  nixpkgs ? null,
}@args:
let
  inherit
    (import ./common.nix (removeAttrs args [ "redistName" ] // { extraOverlays = [ redistOverlay ]; }))
    lib # NOTE: lib doesn't depend on extraOverlays so we can use it to construct redistOverlay.
    releaseLib
    ;

  inherit (lib)
    attrNames
    concatMapAttrs
    genAttrs
    hasAttr
    mapAttrs'
    optionalAttrs
    recurseIntoAttrs
    ;

  # NOTE: Assumes redist is stand-alone -- that it does not depend on other redistributables.
  redistOverlay =
    final: prev:
    genAttrs (attrNames prev.cudaPackagesVersions) (
      cudaPackageSetName:
      let
        cudaPackages = prev.${cudaPackageSetName};
      in
      # Replace each instance of the CUDA package set with just the redists we care about.
      mapAttrs' (redistVersion: redistManifest: {
        name = prev._cuda.lib.mkVersionedName redistName redistVersion;
        value = recurseIntoAttrs (
          concatMapAttrs (
            name: release:
            # Filter for supported packages and releases
            optionalAttrs (hasAttr name cudaPackages) {
              ${name} = cudaPackages.${name}.overrideAttrs (prevAttrs: {
                passthru = prevAttrs.passthru // {
                  inherit release;
                };
              });
            }
          ) redistManifest
        );
      }) prev._cuda.manifests.${redistName}
    );
in
releaseLib.mapTestOn (
  releaseLib.packagePlatforms (
    genAttrs (attrNames releaseLib.pkgs.cudaPackagesVersions) (
      cudaPackageSetName: recurseIntoAttrs releaseLib.pkgs.${cudaPackageSetName}
    )
  )
)
