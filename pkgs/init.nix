{
  writeShellApplication,
}:
writeShellApplication {
  name = "init";
  text = ''
    packages=""
    case ''${1-} in
    node)
      packages='nodejs pnpm'
      ;;
    esac
    echo 'use flake' >.envrc
    cat <<EOF >flake.nix
    {
      inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
      };

      outputs =
        { self, nixpkgs, ... }:
        let
          inherit (nixpkgs) lib;
          forAllSystems = lib.genAttrs lib.systems.flakeExposed;
        in
        {
          devShells = forAllSystems (system: {
            default =
              let
                pkgs = nixpkgs.legacyPackages.\''${system};
                packages = with pkgs; [
                  nil
                  nixfmt-rfc-style
                  $packages
                ];
              in
              derivation {
                name = "shell";
                inherit system packages;
                builder = "\''${pkgs.bash}/bin/bash";
                outputs = [ "out" ];
                stdenv = pkgs.writeTextDir "setup" '''
                  set -e

                  for p in \$packages; do
                    PATH=\$p/bin:\$PATH
                  done
                ''';
              };
          });
        };
    }
    EOF
    direnv allow
  '';
}
