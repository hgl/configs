{
  pkgs',
  util-linux,
  openssl,
  cfssl,
  jq,
}:
pkgs'.writeShellScriptFile "cert" {
  path = ./cert.sh;
  runtimeInputs = [
    util-linux
    openssl
    cfssl
    jq
  ];
}
