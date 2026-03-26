# Vendored GCC Compilers

This directory contains GCC compiler expressions vendored from
[Nixpkgs](https://github.com/NixOS/nixpkgs). We maintain them here because
older CUDA toolkit versions (11.x) require GCC versions (9-12) that have been
removed from upstream Nixpkgs.

## Origin

The GCC subtree was originally extracted from Nixpkgs using `git filter-branch`
(preserving full upstream commit history for `pkgs/development/compilers/gcc/`).

| Milestone | Nixpkgs commit | Date |
|-----------|---------------|------|
| Initial vendoring | `bf0d1707ba1e12471a0b554013187e0c5b74f779` | 2025-04-01 |
| Fast-forward update | `231cae33e7f7d667d9455b026cbb5fd8b9307763` | 2025-10-20 |
| Latest upstream sync | `1b82c5f564a0e07c87f28e8be9776e45723f58f5` | 2026-03-21 |

Dates reflect when the Nixpkgs commit was merged, not its author date.

The fast-forward update (commit `1e6fa6b` in this repo) explicitly reverted four
upstream commits that dropped GCC 9-12:

- `f3186c59` {gcc12,gfortran12,gccgo12,gnat12,gnat-bootstrap12}: drop
- `10ce2b47` {gcc11,gfortran11,gdc11,gnat11,gnat-bootstrap11}: drop
- `4e7ee62b` {gcc10,gfortran10}: drop
- `2a196a72` {gcc9,gfortran9}: drop

## Local modifications

Beyond re-adding the dropped GCC versions, we carry a small number of local
changes:

- **`all.nix`**: The function takes single-component major versions (`"9"`,
  `"10"`, ...) instead of two-component versions. Returns `{ name; value; }`
  attribute sets instead of using `lib.nameValuePair`. Uses
  `builtins.listToAttrs` instead of `lib.listToAttrs`.
- **`versions.nix`**: Retains version entries and source hashes for GCC 9-12.
- **`default.nix`**: Retains version predicates (`atLeast10`, `atLeast11`,
  `is9`, `is10`, etc.) and conditional logic for older GCC versions (e.g.,
  `disableBootstrap` guards, Darwin `cc` vs `c` file extension, hash format
  selection).
- **`patches/default.nix`**: Retains the full three-tier patch structure
  (all-platform, platform-specific, gcc<12-only) including patches for GCC 9-12
  on Darwin, MinGW, musl, etc.
- **`common/dependencies.nix`**: Conditionalizes `libxcrypt` on GCC >= 10.
- **`common/configure-flags.nix`**: Retains `--disable-libsanitizer` for
  mips64+glibc on GCC 12.
- **`common/libgcc.nix`**: `enableLibGccOutput` uses an `or` fallback for
  `isPE` (see "Compatibility with release branches" below).

We also carry 17 extra patch files for GCC 9-12 that upstream no longer ships
(mcf-thread-model backports, `no-sys-dirs` variants, gnat/gfortran fixes, etc.).

## How to sync with upstream

When Nixpkgs makes changes to `pkgs/development/compilers/gcc/`, we port them
here to stay current. The process:

### 1. Identify new upstream commits

```bash
# The commit recorded in "Latest upstream sync" above
LAST_SYNC=1b82c5f564a0e07c87f28e8be9776e45723f58f5

git -C /path/to/nixpkgs log --no-merges --format="%h %ai %s" \
  $LAST_SYNC..HEAD -- pkgs/development/compilers/gcc/
```

### 2. Check branch applicability

This overlay must work against both `master` and the current stable release
branch (e.g., `release-25.11`). For each upstream commit, check which branches
contain it:

```bash
git -C /path/to/nixpkgs merge-base --is-ancestor <commit> release-25.11 \
  && echo "on 25.11" || echo "master only"
```

Our preference is to apply changes unconditionally where possible. Most upstream
GCC changes are safe to include even if they haven't been backported to the
release branch (e.g., a glibc 2.42 compatibility patch is harmless on a glibc
2.40 system).

### 3. Generate patches

```bash
git -C /path/to/nixpkgs format-patch -1 <commit> -o /path/to/patches/
```

Generate one patch per commit. Commits that are part of treewide changes will
include hunks for files outside the GCC tree; these are filtered at apply time.

### 4. Apply with authorship preserved

```bash
git am -3 --include='pkgs/development/compilers/gcc/*' /path/to/patches/*.patch
```

- `--include` strips non-GCC hunks from treewide patches.
- `-3` enables 3-way merge for better conflict resolution.

When `-3` fails (typically for treewide commits where the base tree differs),
fall back to:

```bash
git apply --include='pkgs/development/compilers/gcc/*' -C0 <patch>
```

Then commit manually with the original author metadata:

```bash
GIT_AUTHOR_NAME="..." GIT_AUTHOR_EMAIL="..." GIT_AUTHOR_DATE="..." \
  git commit -m "<original subject>"
```

The author name, email, and date are in the `From:` and `Date:` headers of the
generated patch file.

### 5. Handle compatibility with release branches

Upstream changes may use Nixpkgs library functions or platform attributes that
only exist on `master` and have not been backported to the release branch. Since
our overlay must work against both, use the Nix `or` keyword to provide
fallbacks:

```nix
# Attribute that may not exist on older Nixpkgs:
stdenv.hostPlatform.isPE or (stdenv.hostPlatform.isWindows || stdenv.hostPlatform.isCygwin)

# Team that may not exist:
lib.optionals (teams ? security-review) [ teams.security-review ]

# Lib function that may not exist (check with `?` or provide inline equivalent):
lib.meta.cpeFullVersionWithVendor or (vendor: version: { inherit vendor version; })
```

Known examples from the current sync:

- `isPE` — added in Nixpkgs `3dcf921c` (master only). Equivalent to
  `isWindows || isCygwin`.
- `teams.security-review` — added to Nixpkgs after the current pin and not on
  `release-25.11`.
- `lib.meta.cpeFullVersionWithVendor` — exists on both branches currently, but
  worth checking when the release branch changes.

### 6. Evaluate whether changes should extend to older compilers

Upstream only ships GCC 13+, so their patches are version-guarded accordingly.
When porting, evaluate whether each change should also cover GCC 9-12:

- **Shared infrastructure** (`default.nix`, `common/*.nix`, `builder.nix`):
  changes here affect all versions automatically. No action needed.
- **`patches/default.nix`**: if upstream adds a patch for GCC 13/14, check
  whether the same bug exists in GCC 9-12. The patch file itself may not apply
  cleanly to older sources (different line numbers), so version-specific patches
  or configure flags (e.g., `--disable-libsanitizer`) may be needed.
- **`ng/`**: the next-gen split package set only targets GCC 15+. Changes there
  don't affect older compilers.

### 7. Verify evaluation

After all patches are applied, verify that every GCC version evaluates:

```bash
for v in 9 10 11 12 13 14 15; do
  echo -n "gcc$v: "
  nix eval .#legacyPackages.x86_64-linux.gccVersions.gcc$v.version
done
```

Evaluation failures typically indicate missing attributes in the Nixpkgs pin
(see step 5).

### 8. Resolve conflicts

Most conflicts occur in `patches/default.nix` because our file has ~130 extra
lines for GCC 9-12 patches that upstream doesn't have. The upstream patches
target different line numbers, but the actual changes are typically small
(adding a new `++ optional ...` line or a new patch file). Apply the upstream
intent to the corresponding location in our expanded file.

Conflicts in `all.nix` arise because we restructured the function signature.
Adapt upstream's changes to our function shape.

### 9. Update the overlay if needed

If upstream adds new arguments to `all.nix` or `default.nix`, update
`overlays/gccVersions.nix` to pass them through from the overlay's `final`.

### 10. Update this README

After syncing, update the "Latest upstream sync" row in the table above with
the hash and date of the newest upstream commit incorporated.
