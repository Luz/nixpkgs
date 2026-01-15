{
  stdenv,
  lib,
  fetchFromGitHub,
  qtbase,
  qttools,
  qtsvg,
  qt5compat,
  opencascade-occt,
  libGLU,
  cmake,
  wrapQtAppsHook,
  rustPlatform,
  cargo,
  rustc,
}:

stdenv.mkDerivation rec {
  pname = "librepcb";
  version = "2.0.0-rc1";

  src = fetchFromGitHub {
    owner = "librepcb";
    repo = "librepcb";
    rev = version;
    hash = "sha256-cdDadKVMnEofBzb4hQMyGkrCAYuYlijKm7hA0LRXMMs=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    qttools
    qtsvg
    qt5compat
    wrapQtAppsHook
    opencascade-occt
    libGLU
    cargo
    rustc
  ];
  buildInputs = [ qtbase ];

  cargoDeps1 = rustPlatform.fetchCargoVendor {
    inherit src;
    cargoRoot = "libs/librepcb/rust-core";
    hash = "sha256-1td3WjxbDq2lX7c0trpYRhO82ChNAG/ZABBRsekYtq4=";
  };

  cargoDeps2 = rustPlatform.fetchCargoVendor {
    inherit src;
    cargoRoot = "libs/slint";
    hash = "sha256-DYcKoaOXYFvAi5VyWdhli73s7qrypeXmzGJNhVzcWtY=";
  };


  postPatch = ''
    substituteInPlace libs/librepcb/core/build_env.h.in \
      --replace-fail "@GIT_COMMIT_TIMESTAMP@" "0"

    # Set up cargo config for the first Rust library
    mkdir -p libs/librepcb/rust-core/.cargo
    cat > libs/librepcb/rust-core/.cargo/config.toml <<EOF
    [source.crates-io]
    replace-with = "vendored-sources"
    [source.vendored-sources]
    directory = "${cargoDeps1}"
    EOF

    # Set up cargo config for the second Rust library
    mkdir -p libs/slint/.cargo
    cat > libs/slint/.cargo/config.toml <<EOF
    [source.crates-io]
    replace-with = "vendored-sources"
    [source.vendored-sources]
    directory = "${cargoDeps2}"
    EOF
  '';

  meta = {
    description = "Free EDA software to develop printed circuit boards";
    homepage = "https://librepcb.org/";
    maintainers = with lib.maintainers; [
      luz
      thoughtpolice
    ];
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
  };
}
