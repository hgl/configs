{
  pkgs,
  pkgs',
  config,
  ...
}:
let
  mkLink = config.lib.file.mkOutOfStoreSymlink;
  homeDir = "/Users/hgl/dev/configs/nodes/pcs/hgl/home/hgl";
in
{
  home.file = {
    ".hushlogin".text = "";
    ".config/sops".source = mkLink "${homeDir}/sops";
    ".config/emacs".source = mkLink "${homeDir}/emacs";
    ".config/karabiner/assets/complex_modifications".source = mkLink "${homeDir}/karabiner";
    "Library/Application Support/Code/User/settings.json".source =
      mkLink "${homeDir}/vscode/settings.json";
  };
  home.sessionPath = [
    "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
  ];

  programs.git = {
    ignores = [
      ".DS_Store"
    ];
    extraConfig = {
      gpg = {
        ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      };
    };
  };

  home.shellAliases = {
    e = "${pkgs'.emacs}/bin/emacsclient";
  };

  home.packages = [
    pkgs.mkalias
    (pkgs.writeShellApplication {
      name = "dnsclear";
      text = ''
        sudo dscacheutil -flushcache
        sudo killall -HUP mDNSResponder
      '';
    })
    (pkgs.writeShellApplication {
      name = "serve";
      runtimeInputs = [ pkgs.static-web-server ];
      text = ''
        dir=''${1:-.}
        port=''${2:-8000}
        exec static-web-server --root "$dir" --port "$port" --directory-listing
      '';
    })
    (pkgs.writeShellApplication {
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
    })
  ];
}
