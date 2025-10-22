{
  _cuda,
  callPackage,
  config,
  lib,
}:
let
  # NOTE: Older versions of manifests don't contain `release_label`, so we need to specify the version if it is
  # absent. If it exists, use it as-is.
  selectManifests = lib.mapAttrs (
    name: version:
    let
      manifest = _cuda.manifests.${name}.${version};
    in
    manifest
    // {
      release_label = manifest.release_label or version;
    }
  );

  cudaPackages_11_4 = callPackage ../development/cuda-modules {
    manifests = selectManifests {
      cuda = "11.4.4";
    };
  };

  cudaPackages_11_5 = callPackage ../development/cuda-modules {
    manifests = selectManifests {
      cuda = "11.5.2";
    };
  };

  cudaPackages_11_6 = callPackage ../development/cuda-modules {
    manifests = selectManifests {
      cuda = "11.6.2";
    };
  };

  cudaPackages_11_7 = callPackage ../development/cuda-modules {
    manifests = selectManifests {
      cuda = "11.7.1";
    };
  };

  cudaPackages_11_8 = callPackage ../development/cuda-modules {
    manifests = selectManifests {
      cuda = "11.8.0";
    };
  };

  cudaPackages_12_0 = callPackage ../development/cuda-modules {
    manifests = selectManifests {
      cuda = "12.0.1";
    };
  };

  cudaPackages_12_1 = callPackage ../development/cuda-modules {
    manifests = selectManifests {
      cuda = "12.1.1";
    };
  };

  cudaPackages_12_2 = callPackage ../development/cuda-modules {
    manifests = selectManifests {
      cuda = "12.2.2";
    };
  };

  cudaPackages_12_3 = callPackage ../development/cuda-modules {
    manifests = selectManifests {
      cuda = "12.3.2";
    };
  };

  cudaPackages_12_4 = callPackage ../development/cuda-modules {
    manifests = selectManifests {
      cuda = "12.4.1";
    };
  };

  cudaPackages_12_5 = callPackage ../development/cuda-modules {
    manifests = selectManifests {
      cuda = "12.5.1";
    };
  };

  cudaPackages_12_6 = callPackage ../development/cuda-modules {
    manifests = selectManifests {
      cublasmp = "0.6.0";
      cuda = "12.6.3";
      cudnn = "9.13.0";
      cudss = "0.6.0";
      cuquantum = "25.09.0";
      cusolvermp = "0.7.0";
      cusparselt = "0.6.3";
      cutensor = "2.3.1";
      nppplus = "0.10.0";
      nvcomp = "5.0.0.6";
      nvjpeg2000 = "0.9.0";
      nvpl = "25.5";
      nvtiff = "0.5.1";
      tensorrt = if cudaPackages_12_6.backendStdenv.hasJetsonCudaCapability then "10.7.0" else "10.9.0";
    };
  };

  cudaPackages_12_8 = callPackage ../development/cuda-modules {
    manifests = selectManifests {
      cublasmp = "0.6.0";
      cuda = "12.8.1";
      cudnn = "9.13.0";
      cudss = "0.6.0";
      cuquantum = "25.09.0";
      cusolvermp = "0.7.0";
      cusparselt = "0.8.1";
      cutensor = "2.3.1";
      nppplus = "0.10.0";
      nvcomp = "5.0.0.6";
      nvjpeg2000 = "0.9.0";
      nvpl = "25.5";
      nvtiff = "0.5.1";
      tensorrt = if cudaPackages_12_8.backendStdenv.hasJetsonCudaCapability then "10.7.0" else "10.9.0";
    };
  };

  cudaPackages_12_9 = callPackage ../development/cuda-modules {
    manifests = selectManifests {
      cublasmp = "0.6.0";
      cuda = "12.9.1";
      cudnn = "9.13.0";
      cudss = "0.6.0";
      cuquantum = "25.09.0";
      cusolvermp = "0.7.0";
      cusparselt = "0.8.1";
      cutensor = "2.3.1";
      nppplus = "0.10.0";
      nvcomp = "5.0.0.6";
      nvjpeg2000 = "0.9.0";
      nvpl = "25.5";
      nvtiff = "0.5.1";
      tensorrt = if cudaPackages_12_9.backendStdenv.hasJetsonCudaCapability then "10.7.0" else "10.9.0";
    };
  };

  cudaPackages_13_0 = callPackage ../development/cuda-modules {
    manifests = selectManifests {
      cublasmp = "0.6.0";
      cuda = "13.0.2";
      cudnn = "9.13.0";
      cudss = "0.6.0";
      cuquantum = "25.09.0";
      cusolvermp = "0.7.0";
      cusparselt = "0.8.1";
      cutensor = "2.3.1";
      nppplus = "0.10.0";
      nvcomp = "5.0.0.6";
      nvjpeg2000 = "0.9.0";
      nvpl = "25.5";
      nvtiff = "0.5.1";
      tensorrt = if cudaPackages_13_0.backendStdenv.hasJetsonCudaCapability then "10.7.0" else "10.9.0";
    };
  };
in
{
  inherit
    cudaPackages_11_4
    cudaPackages_11_5
    cudaPackages_11_6
    cudaPackages_11_7
    cudaPackages_11_8
    cudaPackages_12_0
    cudaPackages_12_1
    cudaPackages_12_2
    cudaPackages_12_3
    cudaPackages_12_4
    cudaPackages_12_5
    cudaPackages_12_6
    cudaPackages_12_8
    cudaPackages_12_9
    cudaPackages_13_0
    ;
}
