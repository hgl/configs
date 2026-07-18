{
  lib,
  stdenv,
  zig_0_15,
  runCommand,
  runCommandLocal,
  installShellFiles,
  callPackage,
  writeShellApplication,
  writeShellScriptBin,
  apple-sdk,
  inputs',
}:
let
  zig2nixSrc = inputs'.zig2nix;
  zig2nix-zigless = callPackage "${zig2nixSrc}/src/zig2nix/default.nix" {
    zig = zig_0_15;
  };

  zig2nix = writeShellApplication {
    name = "zig2nix";
    runtimeInputs = [ zig_0_15 ];
    text = ''${zig2nix-zigless}/bin/zig2nix "$@"'';
  };

  exec =
    cmd: args:
    runCommandLocal cmd { } ''
      ZIG_GLOBAL_CACHE_DIR=$TMPDIR/zig2nix ${zig2nix}/bin/zig2nix ${cmd} ${lib.escapeShellArgs args} > $out
    '';
  exec-path =
    cmd: path: args:
    runCommandLocal cmd { } ''
      ZIG_GLOBAL_CACHE_DIR=$TMPDIR/zig2nix ${zig2nix}/bin/zig2nix ${cmd} ${path} ${lib.escapeShellArgs args} > $out
    '';
  exec-json = cmd: args: builtins.fromJSON (builtins.readFile (exec cmd args));
  exec-json-path =
    cmd: path: args:
    builtins.fromJSON (builtins.readFile (exec-path cmd path args));

  target = targetSystem: exec-json "target" [ targetSystem ];
  fromZON = path: exec-json-path "zon2json" path [ ];
  deriveLockFile = path: callPackage (exec-path "zon2nix" path [ "-" ]);

  zigPackage = callPackage (
    callPackage "${zig2nixSrc}/src/package.nix" {
      zig = zig_0_15;
      inherit target fromZON deriveLockFile;
    }
  );

  xcrunWrapper = writeShellScriptBin "xcrun" ''
    echo "${apple-sdk.sdkroot}"
  '';
  xcodeselectWrapper = writeShellScriptBin "xcode-select" ''
    echo "${apple-sdk.sdkroot}"
  '';

  zmx = zigPackage (
    {
      src = lib.cleanSource inputs'.zmx;
      zigPreferMusl = !stdenv.hostPlatform.isDarwin;
      postPatch = ''
        if [[ -e "''${ZIG_GLOBAL_CACHE_DIR:-}/p" ]]; then
          deps_store="$(readlink "$ZIG_GLOBAL_CACHE_DIR/p")"
          deps_cache="$ZIG_GLOBAL_CACHE_DIR/p"
          uucode="uucode-0.2.0-ZZjBPqZVVABQepOqZHR7vV_NcaN-wats0IB6o-Exj6m9"

          rm "$deps_cache"
          mkdir "$deps_cache"
          ln -s "$deps_store"/* "$deps_cache"/
          rm "$deps_cache/$uucode"
          cp -RL "$deps_store/$uucode" "$deps_cache/$uucode"
          chmod -R u+w "$deps_cache/$uucode"
          patch -d "$deps_cache/$uucode" -p1 < ${../../emacs/pkgs/emacs-macport/emacs-libgterm/uucode-nix-macos.patch}
        fi
      '';
    }
    // lib.optionalAttrs stdenv.hostPlatform.isDarwin {
      glibc = null;
      musl = null;
      nativeBuildInputs = [
        xcrunWrapper
        xcodeselectWrapper
      ];
    }
  );
in
runCommand zmx.name
  {
    nativeBuildInputs = [ installShellFiles ];
    meta.mainProgram = "zmx";
  }
  ''
    mkdir -p $out/bin
    ln -s ${zmx}/bin/zmx $out/bin/zmx
    export ZMX_DIR="$TMPDIR/zmx"

    echo '#compdef zmx' > _zmx
    $out/bin/zmx completions zsh >> _zmx
    installShellCompletion --zsh _zmx

    $out/bin/zmx completions bash > zmx.bash
    installShellCompletion --bash zmx.bash

    $out/bin/zmx completions fish > zmx.fish
    installShellCompletion --fish zmx.fish
  ''
