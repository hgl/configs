{
  lib,
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
      buildGoModule = pkgs.buildGoModule;
    in
    {
      packages =
        {
          x86_64-linux = {
            strongswan-unstable = pkgs'.strongswan;
          };
          aarch64-darwin = {
            emacs-unstable = pkgs'.emacs-macport;
            tailscale-utils-unstable = pkgs'.tailscale-utils;
            nixverse = inputs'.nixverse.packages.nixverse;
          };
        }
        .${system} or { };

      devShellPackages = [
        pkgs.nil
        pkgs.nixfmt-rfc-style
        pkgs.shfmt
        pkgs.shellcheck
        pkgs.nodePackages.bash-language-server
        pkgs.nodePackages.yaml-language-server
        pkgs.sops
        pkgs.mkpasswd
        pkgs.go
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
}
