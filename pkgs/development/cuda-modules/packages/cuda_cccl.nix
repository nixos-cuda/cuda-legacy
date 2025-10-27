{
  _cuda,
  backendStdenv,
  buildRedist,
  cmake,
  cuda_cudart,
  cuda_nvcc,
  cudaAtLeast,
  cudaMajorMinorVersion,
  cudaNamePrefix,
  fetchFromGitHub,
  lib,
  markForCudatoolkitRootHook,
  ninja,
  python3,
  setupCudaHook,
}:
let
  fixNameForBootstrap =
    drv:
    drv.overrideAttrs (prevAttrs: {
      name = "${cudaNamePrefix}-${prevAttrs.pname}-bootstrap-${prevAttrs.version}";
    });

  # Create a version of cuda_cudart to use to build cuda_cccl.
  # Since cuda_cudart depends on cuda_cccl and vice versa, we create an instance of cuda_cudart which uses
  # cuda_cccl as provided by CUDA Toolkit, and then use that version of cuda_cudart to build the open-source
  # cuda_cccl library.
  cuda_cccl_bootstrap = fixNameForBootstrap (buildRedist {
    redistName = "cuda";
    pname = "cuda_cccl";

    # Restrict header-only packages to a single output.
    # Also, when using multiple outputs (i.e., `out`, `dev`, and `include`), something isn't being patched correctly,
    # so libnvshmem fails to build, complaining about being unable to find the thrust include directory. This is likely
    # because the `dev` output contains the CMake configuration and is written to assume it will share a parent
    # directory with the include directory rather than be in a separate output.
    outputs = [ "out" ];

    prePatch = lib.optionalString (cudaAtLeast "13.0") ''
      nixLog "removing top-level $PWD/include/nv directory"
      rm -rfv "$PWD/include/nv"
      nixLog "un-nesting top-level $PWD/include/cccl directory"
      mv -v "$PWD/include/cccl"/* "$PWD/include/"
      nixLog "removing empty $PWD/include/cccl directory"
      rmdir -v "$PWD/include/cccl"
    '';

    meta = {
      description = "Building blocks that make it easier to write safe and efficient CUDA C++ code";
      longDescription = ''
        The goal of CCCL is to provide CUDA C++ developers with building blocks that make it easier to write safe and
        efficient code.
      '';
      homepage = "https://github.com/NVIDIA/cccl";
      changelog = "https://github.com/NVIDIA/cccl/releases";
    };
  });

  cuda_nvcc_bootstrap = fixNameForBootstrap (
    cuda_nvcc.override {
      cuda_cccl = cuda_cccl_bootstrap;
    }
  );

  cuda_cudart_bootstrap = fixNameForBootstrap (
    cuda_cudart.override {
      cuda_cccl = cuda_cccl_bootstrap;
      cuda_nvcc = cuda_nvcc_bootstrap;
    }
  );
in
backendStdenv.mkDerivation (
  finalAttrs:
  let
    ccclMajorMinorVersion = lib.versions.majorMinor finalAttrs.version;
  in
  {
    __structuredAttrs = true;
    strictDeps = true;

    # NOTE: Depends on the CUDA package set, so use cudaNamePrefix.
    name = "${cudaNamePrefix}-${finalAttrs.pname}-${finalAttrs.version}";
    pname = "cuda_cccl";

    # https://github.com/NVIDIA/cccl/blob/81b9aa5f1cc5f3d480cb6f1e807824e9b2f72bac/README.md?plain=1#L241-L244
    version = if cudaAtLeast "12" then "3.1.0" else "2.8.5";

    src = fetchFromGitHub {
      owner = "NVIDIA";
      repo = "cccl";
      tag = "v${finalAttrs.version}";
      hash = builtins.getAttr finalAttrs.version {
        "3.1.0" = "sha256-cweqGzBetx98xDg+h0uMIhsn3w/PkpndSQRU0cD9ECg=";
        "2.8.5" = "sha256-fUuJkvj8aH62mULL869KzY75jF8gqwsBzh+TCk5qyEU=";
      };
    };

    # Restrict header-only packages to a single output.
    # Also, when using multiple outputs (i.e., `out`, `dev`, and `include`), something isn't being patched correctly,
    # so libnvshmem fails to build, complaining about being unable to find the thrust include directory. This is likely
    # because the `dev` output contains the CMake configuration and is written to assume it will share a parent
    # directory with the include directory rather than be in a separate output.
    outputs = [ "out" ];

    nativeBuildInputs = [
      cuda_nvcc_bootstrap
      cmake
      ninja
      python3
      markForCudatoolkitRootHook
    ];

    # The search paths are templated such that we end up doubling them:
    # https://github.com/NVIDIA/cccl/blob/d108fb0a29fc28588e0d4f5352e800793e5d1423/lib/cmake/cub/cub-header-search.cmake.in#L12
    # To avoid this, ensure the only component in the template is CMAKE_INSTALL_INCLUDEDIR.
    prePatch = ''
      for component in cub libcudacxx thrust; do
        nixLog "patching $PWD/lib/cmake/$component/$component-header-search.cmake.in"
        substituteInPlace "$PWD/lib/cmake/$component/$component-header-search.cmake.in" \
          --replace-fail \
          '"''${CMAKE_CURRENT_LIST_DIR}/''${from_install_prefix}/' \
          '"/'
      done
      unset -v component
    '';

    propagatedBuildInputs = [
      setupCudaHook
    ];

    buildInputs = [
      cuda_cudart_bootstrap
    ];

    # Mostly taken from
    # 2.8.5: https://github.com/NVIDIA/cccl/blob/d108fb0a29fc28588e0d4f5352e800793e5d1423/CMakePresets.json
    # 3.1.0: https://github.com/NVIDIA/cccl/blob/ecfd3adfaa7ebcb81d80d5b297ab3551619fda02/CMakePresets.json
    cmakeFlags = [
      (lib.cmakeBool "CCCL_ENABLE_UNSTABLE" false)
      (lib.cmakeBool "CCCL_ENABLE_LIBCUDACXX" false)
      (lib.cmakeBool "CCCL_ENABLE_CUB" false)
      (lib.cmakeBool "CCCL_ENABLE_THRUST" false)
      (lib.cmakeBool "CCCL_ENABLE_CUDAX" false)
      (lib.cmakeBool "CCCL_ENABLE_TESTING" false)
      (lib.cmakeBool "CCCL_ENABLE_EXAMPLES" false)
      (lib.cmakeBool "CCCL_ENABLE_C" false)
      (lib.cmakeBool "libcudacxx_ENABLE_INSTALL_RULES" true)
      (lib.cmakeBool "CUB_ENABLE_INSTALL_RULES" true)
      (lib.cmakeBool "Thrust_ENABLE_INSTALL_RULES" true)
      (lib.cmakeBool "cudax_ENABLE_INSTALL_RULES" false)
    ];

    passthru = {
      inherit
        cuda_cccl_bootstrap
        cuda_cudart_bootstrap
        cuda_nvcc_bootstrap
        ;

      # Check that the CCCL major version is being used with an acceptable CUDA release.
      # https://github.com/NVIDIA/cccl/blob/81b9aa5f1cc5f3d480cb6f1e807824e9b2f72bac/README.md?plain=1#L241-L244
      # https://github.com/NVIDIA/cccl/blob/81b9aa5f1cc5f3d480cb6f1e807824e9b2f72bac/README.md?plain=1#L452-L473
      brokenAssertions = cuda_cccl_bootstrap.passthru.brokenAssertions or [ ] ++ [
        {
          message =
            "CCCL 2.8 (found ${finalAttrs.version})"
            + " supports CUDA 11 - 12.9 (found ${cudaMajorMinorVersion})";
          assertion =
            ccclMajorMinorVersion == "2.8"
            -> cudaAtLeast "11" && lib.versionAtLeast "12.9" cudaMajorMinorVersion;
        }
        {
          message =
            "CCCL 3.1 (found ${finalAttrs.version})"
            + " supports CUDA 12 - 13.1 (found ${cudaMajorMinorVersion})";
          assertion =
            ccclMajorMinorVersion == "3.1"
            -> cudaAtLeast "12" && lib.versionAtLeast "13.1" cudaMajorMinorVersion;
        }
        # Ensure assertions stay in sync with constraints
        {
          message = "CCCL 2.8 and 3.1 are supported (found ${finalAttrs.version})";
          assertion = ccclMajorMinorVersion == "2.8" || ccclMajorMinorVersion == "3.1";
        }
      ];

      inherit (cuda_cccl_bootstrap.passthru) platformAssertions;
    };

    # TODO(@connorbaker): Add tests.

    meta = cuda_cccl_bootstrap.meta // {
      broken = _cuda.lib._mkMetaBroken finalAttrs;
      badPlatforms = _cuda.lib._mkMetaBadPlatforms finalAttrs;
    };
  }
)
