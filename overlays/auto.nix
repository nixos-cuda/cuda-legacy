# Adds attributes which do not yet exist to top-level, drawing from
# gccVersions, gccStdenvVersions, and cudaPackagesVersions.
final: prev:
let
  inherit (builtins)
    hasAttr
    mapAttrs
    seq
    tryEval
    ;

  getAttrOr =
    attrs: name: value:
    # Attributes may have been aliases since removed and replaced with throws;
    # can't just check for existence, need to catch errors as well.
    # NOTE: .value is false if eval fails, else it is the result of evaluation.
    # NOTE: We must use seq to force accessing the value, ensuring it is not a throw.
    # NOTE: We cannot use deepSeq as the value may be recursive.
    if (tryEval (seq (attrs.${name} or null) (hasAttr name attrs))).value then attrs.${name} else value;

  # If the attribute exists in `prev` already, pass it through unchanged.
  # Otherwise, use the value provided.
  unchangedIfPresent = mapAttrs (getAttrOr prev);
in
unchangedIfPresent prev.gccVersions
// unchangedIfPresent prev.gccStdenvVersions
// unchangedIfPresent prev.cudaPackagesVersions
// {
  # TODO(@connorbaker): Find a better way to do this, perhaps via groupBy, sorting versions,
  # and choosing the latest for a major release if there isn't one.
  cudaPackages_11 = getAttrOr prev "cudaPackages_11" final.cudaPackagesVersions.cudaPackages_11_8;
}
