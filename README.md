# cuda-legacy

> [!IMPORTANT]
>
> This repository is provided as-is. Use it at your own risk.

A collection of CUDA releases and requisite packages which have aged out of Nixpkgs.

Support is best-effort. Because the ecosystem moves quickly, I (@ConnorBaker) only build and test against the commit pinned in flake.nix. If you are using a commit older than what is in the flake, you are doing so at your own risk.

We generally use commits from the latest stable release branch; the overlay should work with changes on `master` but, again, do so at your own risk.

Currently, that is (always be sure to verify as the README is not kept in sync):

```nix
# nixos-26.05-pre 2026-05-21
nixpkgs = getFlake "github:NixOS/nixpkgs/32ff23b7ead295ae5cca5d731ff87ecce73eee44";
```

# License

`cuda-legacy` originates as a copy of Nixpkgs and is also licensed under the [MIT License](https://github.com/NixOS/nixpkgs/blob/0274b441515c91f499c5713a40a24e36faeb0134/COPYING).
