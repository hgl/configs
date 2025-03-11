{
  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable-nixos.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-stable-darwin.url = "github:NixOS/nixpkgs/nixpkgs-24.05-darwin";
    nix-darwin-unstable = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
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
          pkgs' = self.packages.${system};
        in
        {
          default = pkgs'.mkShellMinimal {
            packages = with pkgs; [
              nixd
              nixfmt-rfc-style
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
              go_1_23
              cfssl
              rsync
              dig
              yq
              util-linux # needs uuidgen
              coreutils # needs base64 date
              (delve.override {
                buildGoModule = buildGo123Module;
              })
              (gopls.override {
                buildGoModule = buildGo123Module;
              })
              (go-tools.override {
                buildGoModule = buildGo123Module;
              })
              pkgs'.tailscale-utils
              pkgs'.nixverse
            ];
          };
        }
      );
    };
}
