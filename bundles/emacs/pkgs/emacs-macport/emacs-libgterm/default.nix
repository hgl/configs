{
  lib,
  stdenv,
  trivialBuild,
  fetchFromGitHub,
  callPackage,
  zig_0_15,
  emacs,
  applyPatches,
}:
let
  src = fetchFromGitHub {
    owner = "rwc9u";
    repo = "emacs-libgterm";
    rev = "5f5516dccb0de06b2233b3492f175c3477f00ef0";
    hash = "sha256-uqeIj7mIpqNiHc8lJiKiV2malUqIRXNGe3ylOT9KAN8=";
  };
  ghosttySrc = applyPatches {
    src = fetchFromGitHub {
      owner = "ghostty-org";
      repo = "ghostty";
      rev = "ca7516bea60190ee2e9a4f9182b61d318d107c6e";
      hash = "sha256-K0thGpbnSOVFiCVnOM7/6nC+aEGczWs8XlemToVMpmk=";
    };
    patches = [ ./ghostty-apple-sdk.patch ];
  };
  deps = callPackage ./deps.nix { };
  gterm = stdenv.mkDerivation {
    name = "gterm";
    inherit src;
    strictDeps = true;

    postUnpack = ''
      mkdir -p $sourceRoot/vendor
      ln -s ${ghosttySrc} $sourceRoot/vendor/ghostty
    '';

    nativeBuildInputs = [
      zig_0_15
    ];

    zigBuildFlags = [
      "--system"
      "${deps}"
      "-Demacs-include=${emacs}/include"
    ];
  };
in
trivialBuild {
  name = "emacs-libgterm";
  inherit src;

  postInstall = ''
    mkdir -p $out/share/emacs/site-lisp/zig-out
    ln -s ${gterm}/lib $out/share/emacs/site-lisp/zig-out/lib
  '';

  meta = {
    description = "Terminal emulator for Emacs using libghostty-vt";
    homepage = "https://github.com/rwc9u/emacs-libgterm";
    license = lib.licenses.gpl3Plus;
  };
}
