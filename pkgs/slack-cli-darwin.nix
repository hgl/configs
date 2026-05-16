{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "slack-cli-darwin";
  version = "4.0.1";

  src = fetchurl {
    url = "https://downloads.slack-edge.com/slack-cli/slack_cli_${finalAttrs.version}_macOS_arm64.tar.gz";
    hash = "sha256-rTJwJEIYP5cBXOtXgSW+aRyf2a69AMMQMFae0daY0fY=";
  };

  sourceRoot = ".";

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 bin/slack "$out/bin/slack"

    runHook postInstall
  '';

  meta = {
    description = "Slack command-line interface";
    homepage = "https://api.slack.com/automation/cli";
    license = lib.licenses.unfree;
    mainProgram = "slack";
    platforms = [ "aarch64-darwin" ];
  };
})
