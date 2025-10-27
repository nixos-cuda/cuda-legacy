{
  _cuda,
  backendStdenv,
  buildRedist,
  cudaMajorVersion,
  cudaMajorMinorVersion,
  lib,
  libcal,
  libcublas,
  libnvshmem,
  nccl,
}:
buildRedist (
  finalAttrs:
  let
    inherit (backendStdenv) cudaCapabilities;
    cublasmpAtLeast = lib.versionAtLeast finalAttrs.version;

    # Create variables and use logical OR to allow short-circuiting.

    cublasmpAtLeast060 = cublasmpAtLeast "0.6.0";

    allCCNewerThan80 = lib.all (lib.flip lib.versionAtLeast "8.0") cudaCapabilities;
    allCCNewerThan75 = allCCNewerThan80 || lib.all (lib.flip lib.versionAtLeast "7.5") cudaCapabilities;
    allCCNewerThan70 = allCCNewerThan75 || lib.all (lib.flip lib.versionAtLeast "7.0") cudaCapabilities;
  in
  {
    redistName = "cublasmp";
    pname = "libcublasmp";

    outputs = [
      "out"
      "dev"
      "include"
      "lib"
    ];

    buildInputs =
      lib.optionals (!cublasmpAtLeast "0.5.0") [
        libcal
      ]
      ++ [
        libcublas
        libnvshmem
        nccl
      ];

    autoPatchelfIgnoreMissingDeps = [
      "libcuda.so.1"
    ];

    # NOTE:
    #
    #   As of this writing, NVIDIA doesn't version their documentation for cublasmp
    #   (https://docs.nvidia.com/cuda/cublasmp/getting_started/index.html). As such, the requirements below come from
    #   the 0.6.0 version of the documentation and whatever can be gleaned from the release notes for prior versions.
    #
    # NOTE:
    #
    #   Unlike restrictions on compute capabilities, which we consider to part of the platform, restrictions on
    #   versions of other software components are used to determine whether the package is marked broken.
    #
    brokenAssertions = [
      {
        message =
          "cuBLASMp releases since 0.6.0 (found ${finalAttrs.version})"
          + " require NVSHMEM 3.3.24 and later (found ${libnvshmem.version})";
        assertion = cublasmpAtLeast060 -> lib.versionAtLeast libnvshmem.version "3.3.24";
      }
      {
        message =
          "cuBLASMp releases since 0.6.0 (found ${finalAttrs.version})"
          + " require NCCL 2.24.3 and later (found ${nccl.version})";
        assertion = cublasmpAtLeast060 -> lib.versionAtLeast nccl.version "2.24.3";
      }
    ];

    platformAssertions = [
      {
        message =
          "cuBLASMp releases for 0.5.1 (found ${finalAttrs.version})"
          + " for CUDA 13 (found ${cudaMajorMinorVersion})"
          + " support CUDA compute capabilities 8.0 and newer (found ${builtins.toJSON cudaCapabilities})";
        assertion =
          _cuda.lib.majorMinorPatch finalAttrs.version == "0.5.1" && cudaMajorVersion == "13"
          -> allCCNewerThan80;
      }
      {
        message =
          "cuBLASMp releases since 0.6.0 (found ${finalAttrs.version})"
          + " for CUDA 12 (found ${cudaMajorMinorVersion})"
          + " support CUDA compute capabilities 7.0 and newer (found ${builtins.toJSON cudaCapabilities})";
        assertion = cublasmpAtLeast060 && cudaMajorVersion == "12" -> allCCNewerThan70;
      }
      {
        message =
          "cuBLASMp releases since 0.6.0 (found ${finalAttrs.version})"
          + " for CUDA 13 (found ${cudaMajorMinorVersion})"
          + " support CUDA compute capabilities 7.5 and newer (found ${builtins.toJSON cudaCapabilities})";
        assertion = cublasmpAtLeast060 && cudaMajorVersion == "13" -> allCCNewerThan75;
      }
    ];

    meta = {
      description = "High-performance, multi-process, GPU-accelerated library for distributed basic dense linear algebra";
      longDescription = ''
        NVIDIA cuBLASMp is a high-performance, multi-process, GPU-accelerated library for distributed basic dense linear
        algebra.

        cuBLASMp is compatible with 2D block-cyclic data layout and provides PBLAS-like C APIs.
      '';
      homepage = "https://docs.nvidia.com/cuda/cublasmp";
      changelog = "https://docs.nvidia.com/cuda/cublasmp/release_notes";
      license = _cuda.lib.licenses.math_sdk_sla;
    };
  }
)
