{
  lib,
  inputs,
  getPkgs',
  flakeModules',
  ...
}:
{
  imports = [
    flakeModules'.devShellPackages
  ];

  systems = lib.systems.flakeExposed;

  perSystem =
    {
      system,
      inputs',
      pkgs,
      pkgs',
      ...
    }:
    let
      buildGoModule = pkgs.buildGo124Module;
    in
    {
      devShellPackages = [
        pkgs.nil
        pkgs.nixfmt-rfc-style
        pkgs.shfmt
        pkgs.shellcheck
        pkgs.nodePackages.bash-language-server
        pkgs.nodePackages.yaml-language-server
        pkgs.sops
        pkgs.mkpasswd
        pkgs.go_1_24
        (pkgs.delve.override { inherit buildGoModule; })
        (pkgs.gopls.override { buildGoLatestModule = buildGoModule; })
        (pkgs.go-tools.override { inherit buildGoModule; })
        pkgs'.cert
        inputs'.nixverse.packages.nixverse
      ];
      makefileInputs = [
        pkgs.openssh
        pkgs.cfssl
        pkgs.yq
        pkgs.coreutils
        pkgs.util-linux # needs uuidgen
        (pkgs'.tailscale-utils.override { inherit buildGoModule; })
        pkgs'.key-cert-match
        pkgs'.mobileconfig
        inputs'.nixverse.packages.nixverse
      ];
    };

  flake.packages = {
    x86_64-linux =
      let
        pkgsUnstable = inputs.nixpkgs-unstable.legacyPackages.x86_64-linux;
        pkgsUnstable' = getPkgs' pkgsUnstable;
      in
      {
        strongswan-unstable = pkgsUnstable'.strongswan;
      };
    aarch64-darwin =
      let
        pkgsUnstable = inputs.nixpkgs-unstable.legacyPackages.aarch64-darwin;
        pkgsUnstable' = getPkgs' pkgsUnstable;
      in
      {
        emacs-unstable = pkgsUnstable'.emacs;
        tailscale-utils-unstable = pkgsUnstable'.tailscale-utils;
        nixverse = inputs.nixverse.packages.aarch64-darwin.nixverse;
      };
  };
}
