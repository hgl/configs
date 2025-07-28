top@{
  lib,
  flake-parts-lib,
  ...
}:
let
  inherit (lib) types;
  inherit (flake-parts-lib)
    mkSubmoduleOptions
    mkPerSystemOption
    ;
in
{
  options = {
    flake = mkSubmoduleOptions {
      devShellPackages = lib.mkOption {
        type = types.lazyAttrsOf (types.listOf types.package);
        default = { };
      };
    };
    perSystem = mkPerSystemOption {
      _file = ./devShellPackages.nix;
      options = {
        devShellPackages = lib.mkOption {
          type = types.listOf types.package;
          default = [ ];
        };
      };
    };
  };

  config = {
    perSystem =
      {
        system,
        pkgs,
        config,
        ...
      }:
      {
        devShells = {
          default = derivation {
            name = "shell";
            inherit system;
            packages = top.config.${system}.devShellPackages or [ ] ++ config.devShellPackages;
            builder = "${pkgs.bash}/bin/bash";
            outputs = [ "out" ];
            stdenv = pkgs.writeTextDir "setup" ''
              set -e

              for p in $packages; do
                PATH=$p/bin:$PATH
              done
            '';
          };
        };
      };
  };
}
