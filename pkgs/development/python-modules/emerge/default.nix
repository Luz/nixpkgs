{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  stdenv,
  gmsh,
  hatchling,
  joblib,
  libGLU,
  loguru,
  numpy,
  numba,
  matplotlib,
  mkl,
  msgpack-numpy,
  psutil,
  python,
  pyvista,
  scipy,
}:

let
  pythonVersion = with lib.versions; "${major python.version}${minor python.version}";

  emsutil = buildPythonPackage rec {
    pname = "emsutil";
    version = "4636a749a519fe4090c4a7adbbbaa7eaf5a77d15";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "FennisRobert";
      repo = "emsutil";
      rev = "4636a749a519fe4090c4a7adbbbaa7eaf5a77d15";
      sha256 = "sha256-CtPppyNnpo6wFmX75iigma3c+sBWx3X/V3FwhQE0GSI=";
    };

  patchPhase = ''
    sed -i 's/numpy>=1.24, <2.3/numpy>=1.24, <2.5/g' pyproject.toml
    sed -i 's/msgpack>=1.1.2/msgpack>=1.1.1/g' pyproject.toml
  '';

    build-system = [ hatchling ];

    dependencies = [
      loguru
      numpy
      matplotlib
      msgpack-numpy
      pyvista
      scipy
    ];
  };
in
buildPythonPackage rec {
  pname = "emerge";
  version = "v2.4.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "FennisRobert";
    repo = "EMerge";
    tag = version;
    sha256 = "sha256-ZKH1+yOgxqDktYDxrzhu6weyT4eW/KlXOgb1Di2ATBQ=";
  };

  propagatedBuildInputs = [ emsutil ];

  patchPhase = ''
    sed -i 's/psutil>=7.2.2/psutil>=7.2.1/g' pyproject.toml
    sed -i 's/msgpack>=1.1.2/msgpack>=1.1.1/g' pyproject.toml
  '';

  build-system = [ hatchling ];

  dependencies = [
    gmsh
    joblib
    libGLU
    loguru
    numpy
    numba
    matplotlib
    mkl
    msgpack-numpy
    psutil
    pyvista
    scipy
  ];

  # Exclude mkl "mkl not installed", it is optional anyway.
  dontCheckRuntimeDeps = true;

  meta = {
    description = "Python bindings for EMerge";
    license = lib.licenses.gpl2;
  };
}

