{ lib, stdenv, fetchurl, autoPatchelfHook }:

let
  version = "0.0.39";

  sources = {
    x86_64-linux = {
      url = "https://github.com/FilenCloudDienste/filen-cli/releases/download/v${version}/filen-cli-v${version}-linux-x64";
      hash = "sha256-1j48mb18p43sa7dp6xb9abpm56llg2g6k65zc56jp1k7446fqsia";
    };
    aarch64-linux = {
      url = "https://github.com/FilenCloudDienste/filen-cli/releases/download/v${version}/filen-cli-v${version}-linux-arm64";
      hash = lib.fakeHash;  # Update this if you need ARM support
    };
  };

  src = fetchurl {
    inherit (sources.${stdenv.hostPlatform.system}) url hash;
  };
in
stdenv.mkDerivation {
  pname = "filen-cli";
  inherit version src;

  nativeBuildInputs = [ autoPatchelfHook ];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/filen
    runHook postInstall
  '';

  meta = {
    description = "CLI for Filen end-to-end encrypted cloud storage";
    homepage = "https://github.com/FilenCloudDienste/filen-cli";
    license = lib.licenses.agpl3Only;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = lib.attrNames sources;
    mainProgram = "filen";
  };
}
