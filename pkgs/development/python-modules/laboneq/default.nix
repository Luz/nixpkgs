{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  rustPlatform,
  cargo,
  pythonOlder,
  # runtime
  numpy,
  scipy,
  matplotlib,
  flask,
  pygments,
  intervaltree,
  jsonschema,
  sqlitedict,
  websockets,
  requests,
  python-box,
  orjson,
  typing-extensions,
  pyyaml,
  rich,
  sortedcollections,
  pybase64,
}:

buildPythonPackage rec {
  pname = "laboneq";
  version = "2.41.0";
  pyproject = true;

  # meson-python: Requires python >=3.10
  # sqlitedict: Test fails due to certificate check. Requires python >=3.11
  disabled = pythonOlder "3.11";

  src = fetchFromGitHub {
    owner = "zhinst";
    repo = "${pname}";
    rev = "${version}";
    hash = "sha256-d5VJhGwMOa0Ps2j88FZq259zGquExIxR+zPMTmqolVA=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    sourceRoot = "${src.name}/src/rust";
    hash = "sha256-uqH5uUXVdupyVCkdIdnaa9O6vJZVuXetJVDJrh9gjgI=";
  };

  propagatedBuildInputs = [
    # Packaged yet:
    numpy scipy matplotlib flask pygments intervaltree jsonschema sqlitedict websockets requests python-box orjson typing-extensions pyyaml rich sortedcollections pybase64
    # Not packaged under nixos yet:
    #engineering_notation openpulse openqasm3 lagom zhinst-core zhinst-toolkit zhinst-utils zhinst-timing-models labone unsync
  ];
  # For current testing, checkout this branch
    # git clone ...
  # Then build the package and activate a shell, also including pip
    # nix-shell -E "with import ~/tools/nixpkgs {}; mkShell { buildInputs = [ python312Packages.laboneq python312Packages.pip ]; }"
  # To get the missing dependencies, create a requirements.txt
    #engineering_notation >= 0.10.0
    #openpulse >= 0.5.0
    #openqasm3 >= 0.5.0, < 1.0
    #lagom >= 2.6.0
    #zhinst-core ~= 24.10.64896
    #zhinst-toolkit == 0.7.0
    #zhinst-utils == 0.5.0
    #zhinst-timing-models ~= 24.10.64896
    #labone == 3.1.0
    #unsync == 1.4.0
  # Then install the missing dependencies in the local directory
    # python -m venv venv
    # source venv/bin/activate
    # pip install -r requirements.txt


# If only python stuff shall be built: sourceRoot = "${src.name}/src/rust";

  #Use the "Alternate Python source directory (src layout), according:
  #https://github.com/PyO3/maturin/blob/main/guide/src/project_layout.md
  postUnpack = "mv ${src.name}/src/rust ${src.name}/rust";
  patchPhase = ''
    substituteInPlace pyproject.toml --replace-fail "./src/rust/Cargo.toml" "./rust/Cargo.toml"
  '';

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  # As we do have some packages that are missing, we ignore this check for now.
  # A workaround for now is to install the missing dependencies via pip into a venv.
  dontCheckRuntimeDeps = true;

  meta = with lib; {
    description = "Public repository for LabOne Q";
    downloadPage = "https://github.com/zhinst/laboneq";
    homepage = "https://github.com/zhinst/laboneq";
    license = "apache-2.0";
    maintainers = with maintainers; [ Luz ];
  };
}
