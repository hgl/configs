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
stdenv.mkDerivation (finalAttrs: {
  pname = "strongswan";
  version = "6.0.2";
  src = fetchFromGitHub {
    owner = "strongswan";
    repo = "strongswan";
    rev = finalAttrs.version;
    hash = "sha256-wjz41gt+Xu4XJkEXRRVl3b3ryEoEtijeqmfVFoRjnA4=";
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
    "--sysconfdir=/etc"
    "--with-systemdsystemunitdir=${placeholder "out"}/etc/systemd/system"
    "--disable-defaults"
    "--disable-shared"
    "--enable-static"
    "--enable-monolithic"
    "--enable-systemd"
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
})
