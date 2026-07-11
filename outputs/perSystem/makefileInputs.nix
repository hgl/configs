{ pkgs, outputs', ... }:
with pkgs;
[
  openssh
  cfssl
  yq
  coreutils
  util-linux # needs uuidgen
  outputs'.packages.cert
  outputs'.packages.key-cert-match
  outputs'.packages.mobileconfig
  outputs'.packages.tailscale-utils
  outputs'.packages.nixverse
]
