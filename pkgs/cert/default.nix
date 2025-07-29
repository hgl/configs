{
  pkgs',
  util-linux,
  openssl,
  cfssl,
  jq,
}:
pkgs'.writeShellScriptFile ./cert.sh [
  util-linux
  openssl
  cfssl
  jq
]
