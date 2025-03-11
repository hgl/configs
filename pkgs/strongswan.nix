{
  lib,
  stdenv,
  fetchFromGitHub,
  openssl,
  gmp,
  systemd,
  autoreconfHook,
  pkg-config,
  perl,
  gperf,
  bison,
  flex,
  python3,
}:
stdenv.mkDerivation rec {
  pname = "strongswan";
  version = "6.0.0";
  src = fetchFromGitHub {
    owner = "strongswan";
    repo = "strongswan";
    rev = version;
    hash = "sha256-SOl5MXSnmfMo1/LTFuT1P+rQf3Wn9kdxUtUgRxrN9VM=";
  };
  enableParallelBuilding = true;
  dontPatchELF = true;
  nativeBuildInputs = [
    pkg-config
    autoreconfHook
    perl
    gperf
    bison
    flex
    python3
  ];
  buildInputs = [
    openssl
    gmp
    systemd.dev
  ];
  NIX_LDFLAGS = lib.optionalString stdenv.cc.isGNU "-lgcc_s";
  configureFlags = [
    "--disable-defaults"
    "--disable-shared"
    "--enable-static"
    "--enable-monolithic"
    "--enable-systemd"
    "--with-systemdsystemunitdir=${placeholder "out"}/etc/systemd/system"
    "--enable-ikev2"
    "--enable-nonce"
    "--enable-swanctl"
    "--enable-kernel-netlink"
    "--enable-openssl"
    "--enable-pem"
    "--enable-socket-default"
    "--enable-vici"
    "--enable-x509"
    "--enable-pkcs1"
    "--enable-revocation"
  ];
}
