{
  pkgs',
  coreutils,
  util-linux,
  openssl,
  yq,
  gnused,
  nixverse,
}:
pkgs'.writeShellScriptFile "mobileconfig" {
  path = ./mobileconfig.sh;
  runtimeInputs = [
    coreutils
    util-linux
    openssl
    yq
    gnused
    nixverse
    pkgs'.cert
  ];
}
