{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  git,
  bison,
  flex,
  curl,
  openssl,
  boost,
  openblas,
  aws-sdk-cpp,
  faiss,
  zlib,
  llvmPackages ? null,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "turingdb";
  version = "1.20";

  src = fetchFromGitHub {
    owner = "turing-db";
    repo = "turingdb";
    rev = "f10b6f02c5879c2a4518518efbcd55e3a1642a8d";
    hash = "sha256-SPNG4CpcwN68GgTPLoH/+MdUV3BnOK6cpBsgm8zNjQY=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    git
    bison
    flex
  ];

  buildInputs = [
    curl
    openssl
    boost
    openblas
    aws-sdk-cpp
    faiss
    zlib
  ] ++ lib.optionals stdenv.isDarwin [llvmPackages.openmp];

  env.NIX_CFLAGS_COMPILE = "-DHEAD_COMMIT_TIMESTAMP=${toString builtins.currentTime}";

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DCMAKE_CXX_FLAGS=-fopenmp"
  ] ++ lib.optionals stdenv.isDarwin [
    "-DOpenMP_CXX_FLAGS=-fopenmp"
    "-DOpenMP_CXX_LIB_NAMES=omp"
    "-DOpenMP_omp_LIBRARY=${lib.getLib llvmPackages.openmp}/lib/libomp.dylib"
  ];

  preConfigure = ''
    if [ ! -d "common/.git" ]; then
      echo "Warning: Submodules might not be properly initialized"
    fi
  '';

  # Tests are disabled because they require network access and external dependencies
  # that are not available in the Nix build sandbox
  doCheck = false;

  meta = with lib; {
    description = "High performance in-memory column-oriented graph database engine";
    longDescription = ''
      TuringDB is a high-performance in-memory column-oriented graph database engine
      designed for analytical and read-intensive workloads. Built from scratch in C++,
      it delivers millisecond query latency on graphs with millions of nodes and edges.

      Key features:
      - 0.1-50ms query latency for analytical queries on 10M+ node graphs
      - Zero-lock concurrency model
      - Git-like versioning system for graphs
      - OpenCypher query language support
      - Python SDK with comprehensive API
    '';
    homepage = "https://turingdb.ai";
    changelog = "https://github.com/turing-db/turingdb/releases";
    license = lib.licenses.bsl11;
    platforms = [ "x86_64-linux" "aarch64-darwin" ];
    mainProgram = "turingdb";
    maintainers = with maintainers; [ roquess ];
  };
})
