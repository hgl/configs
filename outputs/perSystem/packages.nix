{
  pkgs,
  pkgs',
  inputs',
  ...
}:
let
  buildGoModule = pkgs.buildGoModule;
in
{
  cert = pkgs'.cert;
  delve = pkgs.delve.override { inherit buildGoModule; };
  gopls = pkgs.gopls.override { buildGoLatestModule = buildGoModule; };
  go-tools = pkgs.go-tools.override { inherit buildGoModule; };
  key-cert-match = pkgs'.key-cert-match;
  mobileconfig = pkgs'.mobileconfig;
  nixverse = inputs'.nixverse.packages.nixverse;
  tailscale-utils = pkgs'.tailscale-utils.override { inherit buildGoModule; };
}
