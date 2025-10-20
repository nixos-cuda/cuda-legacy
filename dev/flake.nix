{
  # Private inputs for `dev` partition.
  # These are used by the top level flake in the `dev` partition, but do not appear in consumers' lock files.

  # NOTE: Nixpkgs is passed as an input by the top-level flake.nix, inside the creation of the partition.
  # If we provide `nixpkgs.follows = "";`, evaluation fails because the inputs are resolved prior to
  # flake-parts providing explicit inputs.
  inputs = {
    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "";
    };
  };

  # This flake is only used for its inputs.
  outputs = _: { };
}
