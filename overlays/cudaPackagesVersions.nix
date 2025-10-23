final: prev: {
  # Top-level fix-point used in `cudaPackages`' internals
  _cuda = prev._cuda.extend (
    finalCuda: prevCuda: {
      # TODO: Ideally we would add manifests but avoid replacing ones which are already present (e.g., from upstream).
      manifests = import ../pkgs/development/cuda-modules/_cuda/manifests { inherit (final) lib; };

      # The package sets are unchanged except for the expressions we keep in-tree.
      # If we need to replace a package expression, add an extension to _cuda.extensions and callPackage the
      # replacement.
    }
  );

  cudaPackagesVersions =
    let
      mkCudaPackages =
        manifestVersions:
        final.callPackage final._cuda.bootstrapData.cudaPackagesPath {
          manifests = final._cuda.lib.selectManifests manifestVersions;
        };
    in
    {
      cudaPackages_11_4 = mkCudaPackages {
        cuda = "11.4.4";
      };

      cudaPackages_11_5 = mkCudaPackages {
        cuda = "11.5.2";
      };

      cudaPackages_11_6 = mkCudaPackages {
        cuda = "11.6.2";
      };

      cudaPackages_11_7 = mkCudaPackages {
        cuda = "11.7.1";
      };

      cudaPackages_11_8 = mkCudaPackages {
        cuda = "11.8.0";
      };

      cudaPackages_12_0 = mkCudaPackages {
        cuda = "12.0.1";
      };

      cudaPackages_12_1 = mkCudaPackages {
        cuda = "12.1.1";
      };

      cudaPackages_12_2 = mkCudaPackages {
        cuda = "12.2.2";
      };

      cudaPackages_12_3 = mkCudaPackages {
        cuda = "12.3.2";
      };

      cudaPackages_12_4 = mkCudaPackages {
        cuda = "12.4.1";
      };

      cudaPackages_12_5 = mkCudaPackages {
        cuda = "12.5.1";
      };

      cudaPackages_12_6 =
        let
          inherit (final.cudaPackagesVersions.cudaPackages_12_6.backendStdenv) hasJetsonCudaCapability;
        in
        mkCudaPackages {
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
          tensorrt = if hasJetsonCudaCapability then "10.7.0" else "10.9.0";
        };

      cudaPackages_12_8 =
        let
          inherit (final.cudaPackagesVersions.cudaPackages_12_8.backendStdenv) hasJetsonCudaCapability;
        in
        mkCudaPackages {
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
          tensorrt = if hasJetsonCudaCapability then "10.7.0" else "10.9.0";
        };

      cudaPackages_12_9 =
        let
          inherit (final.cudaPackagesVersions.cudaPackages_12_9.backendStdenv) hasJetsonCudaCapability;
        in
        mkCudaPackages {
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
          tensorrt = if hasJetsonCudaCapability then "10.7.0" else "10.9.0";
        };

      cudaPackages_13_0 =
        let
          inherit (final.cudaPackagesVersions.cudaPackages_13_0.backendStdenv) hasJetsonCudaCapability;
        in
        mkCudaPackages {
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
          tensorrt = if hasJetsonCudaCapability then "10.7.0" else "10.9.0";
        };
    };
}
