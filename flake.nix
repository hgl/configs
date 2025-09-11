{
  inputs = {
    self.submodules = true;
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable-nixos.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-stable-darwin.url = "github:NixOS/nixpkgs/nixpkgs-24.05-darwin";
    determinate-unstable.url = "github:DeterminateSystems/determinate";
    nix-darwin-unstable = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    disko-unstable = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    sops-nix-unstable = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nix-networkd-unstable = {
      url = "github:hgl/nix-networkd";
      # url = "/Users/hgl/dev/nix-networkd";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    virby-unstable-darwin = {
      url = "github:quinneden/virby-nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nixverse = {
      url = "github:hgl/nixverse";
      # url = "/Users/hgl/dev/nixverse";
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
