args@{ lib, pkgs }:
let
  recursiveMapPackages =
    let
      canEvalDrvPath = drv: (builtins.tryEval (builtins.seq drv.drvPath drv.drvPath)).success;
    in
    lib.concatMapAttrs (
      name: value:
      if lib.isDerivation value then
        # If we can evaluate the drvPath, trim it for hydraJobs, otherwise include it as-is so we get
        # an error when we try to evaluate/build the package.
        { ${name} = if canEvalDrvPath value then lib.hydraJob value else value; }
      else if value.recurseForDerivations or false || value.recurseForRelease or false then
        { ${name} = recursiveMapPackages value; }
      else
        { }
    );

  pkgsFor =
    cudaPackageSetName:
    let
      # `pkgs` is an instance of Nixpkgs where the enclosing CUDA package set is the default version.
      inherit (args.pkgs.${cudaPackageSetName}) pkgs;
    in
    recursiveMapPackages {
      inherit (pkgs)
        blas
        blender
        cctag # Failed in https://github.com/NixOS/nixpkgs/pull/233581
        cholmod-extra
        colmap
        ctranslate2
        faiss
        ffmpeg-full
        gimp
        gpu-screen-recorder
        lapack
        lightgbm
        llama-cpp
        magma
        meshlab
        monado # Failed in https://github.com/NixOS/nixpkgs/pull/233581
        mpich
        noisetorch
        ollama
        onnxruntime
        opencv
        openmpi
        openmvg
        openmvs
        opentrack
        openvino
        pixinsight # Failed in https://github.com/NixOS/nixpkgs/pull/233581
        qgis
        rtabmap
        saga
        suitesparse
        sunshine
        truecrack-cuda
        tts
        ucx
        ueberzugpp # Failed in https://github.com/NixOS/nixpkgs/pull/233581
        wyoming-faster-whisper
        xgboost
        ;

      cudaPackages = lib.recurseIntoAttrs pkgs.cudaPackages;

      gst_all_1 = lib.recurseIntoAttrs {
        inherit (pkgs.gst_all_1) gst-plugins-bad;
      };

      obs-studio-plugins = lib.recurseIntoAttrs {
        inherit (pkgs.obs-studio-plugins) obs-backgroundremoval;
      };

      python3Packages = lib.recurseIntoAttrs {
        inherit (pkgs.python3Packages)
          catboost
          cupy
          faiss
          faster-whisper
          flax
          gpt-2-simple
          grad-cam
          jax
          jaxlib
          keras
          kornia
          mmcv
          mxnet
          numpy # Only affected by MKL?
          onnx
          openai-whisper
          opencv4
          opensfm
          pycuda
          pymc
          pyrealsense2WithCuda
          pytorch-lightning
          scikit-image
          scikit-learn # Only affected by MKL?
          scipy # Only affected by MKL?
          spacy-transformers
          tensorflow
          tensorflow-probability
          tesserocr
          tiny-cuda-nn
          torch
          torchaudio
          torchvision
          transformers
          triton
          ttstokenizer
          vidstab
          vllm
          ;
      };
    };

  # NOTE: Not all packages are written to support earlier CUDA versions.
  # For example, cupy needs the CUDA profiler API, which isn't available in early versions.
  # NOTE: Our overlays do not change the major-versioned or unversioned package sets (e.g., cudaPackages_12,
  # cudaPackages).
  cudaPackageSetNames = [
    "cudaPackages_11_8"
    "cudaPackages_12_2"
    "cudaPackages_12_6"
  ];
in
lib.genAttrs cudaPackageSetNames pkgsFor
