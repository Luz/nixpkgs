{ stdenv
, lib
, fetchFromGitHub
, qmake
, qtbase
, qtwebengine
, wrapQtAppsHook
}:

stdenv.mkDerivation rec {
  pname = "openfortivpn-webview";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "gm-vm";
    repo = pname;
    rev = "2ab18db479166e66865529570a3645b21d2e8944";
    hash = "sha256-HheqDjlWxHJS0+OEhRTwANs9dyz3lhhCmWh+YH4itOk=";
  };

  sourceRoot = "source/openfortivpn-webview-qt";

  nativeBuildInputs = [ qmake wrapQtAppsHook ];
  buildInputs = [ qtwebengine ];

  installPhase = "install -Dm755 ${pname} -t $out/bin";

  meta = with lib; {
    description = "Application to perform the SAML single sing-on and easily retrieve the SVPNCOOKIE needed by openfortivpn.";
    homepage = "https://github.com/gm-vm/openfortivpn-webview";
    license = licenses.mit;
    maintainers = with maintainers; [ luz ];
    platforms = platforms.linux;
  };
}

