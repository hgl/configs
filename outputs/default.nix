{
  lib,
  flakeModules',
  nodes,
  ...
}:
{
  imports = [
    flakeModules'.devShellPackages
  ];

  systems = lib.systems.flakeExposed;

  flake = {
    packages = {
      x86_64-linux = {
        dnsmasq = nodes.r0.pkgs.dnsmasq;
        nftables = nodes.r0.pkgs.nftables;
        nginx = nodes.s0.config.services.nginx.package;
        strongswan = nodes.s0.config.services.strongswan-swanctl.package;
      };
      aarch64-linux = {
        codex = nodes.vm-nixos.config.home-manager.users.hgl.programs.codex.package;
        vercel = nodes.vm-nixos.pkgs'.vercel;
      };
      aarch64-darwin = {
        emacs-macport = nodes.hgl.pkgs'.emacs-macport;
        codex = nodes.hgl.config.home-manager.users.hgl.programs.codex.package;
        vercel = nodes.hgl.pkgs'.vercel;
      };
    };
  };

  perSystem =
    {
      config,
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
      packages = {
        cert = pkgs'.cert;
        delve = pkgs.delve.override { inherit buildGoModule; };
        gopls = pkgs.gopls.override { buildGoLatestModule = buildGoModule; };
        go-tools = pkgs.go-tools.override { inherit buildGoModule; };
        key-cert-match = pkgs'.key-cert-match;
        mobileconfig = pkgs'.mobileconfig;
        nixverse = inputs'.nixverse.packages.nixverse;
        tailscale-utils = pkgs'.tailscale-utils.override { inherit buildGoModule; };
      };

      devShellPackages = with pkgs; [
        nil
        nixfmt
        shfmt
        shellcheck
        bash-language-server
        yaml-language-server
        sops
        mkpasswd
        go
        config.packages.cert
        config.packages.delve
        config.packages.gopls
        config.packages.go-tools
        config.packages.nixverse
      ];
      makefileInputs = with pkgs; [
        openssh
        cfssl
        yq
        coreutils
        util-linux # needs uuidgen
        config.packages.key-cert-match
        config.packages.mobileconfig
        config.packages.tailscale-utils
        config.packages.nixverse
      ];
    };
}
