{
  inputs = {
    self.submodules = true;
    nixpkgs-unstable-nixos.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    # nixpkgs-unstable.url = "/Users/hgl/contrib/nixpkgs";
    nix-darwin-unstable = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    disko-unstable-nixos = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-unstable-nixos";
    };
    home-manager-unstable-nixos = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable-nixos";
    };
    home-manager-unstable-darwin = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    sops-nix-unstable-nixos = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable-nixos";
    };
    sops-nix-unstable-darwin = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nix-networkd-unstable-nixos = {
      url = "github:hgl/nix-networkd";
      # url = "/Users/hgl/dev/nix/nix-networkd";
      inputs.nixpkgs.follows = "nixpkgs-unstable-nixos";
    };
    nixverse = {
      url = "github:hgl/nixverse";
      # url = "/Users/hgl/dev/nix/nixverse";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    inputs@{ nixverse, ... }:
    nixverse.lib.load {
      inherit inputs;
      flakePath = ./.;
    };
}
