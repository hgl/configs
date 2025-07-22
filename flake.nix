{
  inputs = {
    self.submodules = true;
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable-nixos.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-master-darwin.url = "github:NixOS/nixpkgs/master";
    nixpkgs-stable-darwin.url = "github:NixOS/nixpkgs/nixpkgs-24.05-darwin";
    nix-darwin-unstable = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nix-darwin-master-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-master-darwin";
    };
    nix-darwin-stable-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-stable-darwin";
    };
    disko-unstable = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    disko-stable-nixos = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-stable-nixos";
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    home-manager-stable-nixos = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-stable-nixos";
    };
    home-manager-master-darwin = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-master-darwin";
    };
    home-manager-stable-darwin = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-stable-darwin";
    };
    sops-nix-unstable = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    sops-nix-stable-nixos = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-stable-nixos";
    };
    sops-nix-stable-darwin = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-stable-darwin";
    };
    networkd-ipmon-unstable = {
      url = "github:hgl/networkd-ipmon";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nixos-router-unstable = {
      url = "/Users/hgl/dev/nixos-router";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nixverse = {
      # url = "github:hgl/nixverse";
      url = "/Users/hgl/dev/nixverse";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    {
      self,
      nixpkgs-unstable,
      nixverse,
      ...
    }:
    nixverse.load self {
      devShells = nixverse.lib.forAllSystems (
        system:
        let
          pkgs = nixpkgs-unstable.legacyPackages.${system};
          pkgs' = nixverse.loadPkgs' self {
            inherit system;
            nixpkgs = nixpkgs-unstable;
          };
          buildGoModule = pkgs.buildGo124Module;
          packages = with pkgs; [
            nil
            nixfmt-rfc-style
            shfmt
            shellcheck
            nodePackages.bash-language-server
            nodePackages.yaml-language-server
            nixos-rebuild
            gnutar
            mkpasswd
            openssh
            jq
            curl
            gawk
            ssh-to-age
            sops
            age
            go_1_24
            cfssl
            rsync
            dig
            yq
            util-linux # needs uuidgen
            coreutils # needs base64 date
            (delve.override { inherit buildGoModule; })
            (gopls.override { buildGoLatestModule = buildGoModule; })
            (go-tools.override { inherit buildGoModule; })
            (pkgs'.tailscale-utils.override { inherit buildGoModule; })
            pkgs'.nixverse
          ];
        in
        {
          default = derivation {
            name = "shell";
            inherit system packages;
            builder = "${pkgs.bash}/bin/bash";
            outputs = [ "out" ];
            stdenv = pkgs.writeTextDir "setup" ''
              set -e

              for p in $packages; do
                PATH=$p/bin:$PATH
              done
            '';
          };
        }
      );
    };
}
