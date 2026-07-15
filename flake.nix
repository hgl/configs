{
  inputs = {
    self.submodules = true;
    nixpkgs-unstable-nixos.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
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
    llm-agents-unstable = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    zmx-unstable = {
      url = "github:neurosnap/zmx";
      flake = false;
    };
    paneru-unstable = {
      url = "github:karinushka/paneru/4a635d8dd7bed0c1eb43b6b85788b1db58e0500f";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    zig2nix-unstable = {
      url = "github:Cloudef/zig2nix";
      flake = false;
    };
    rust-overlay-unstable = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
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
