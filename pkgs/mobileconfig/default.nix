{
  pkgs',
  coreutils,
  util-linux,
  openssl,
  yq,
  gnused,
  nixverse,
}:
pkgs'.writeShellScriptFile ./mobileconfig.sh [
  coreutils
  util-linux
  openssl
  yq
  gnused
  nixverse
  pkgs'.cert
]
