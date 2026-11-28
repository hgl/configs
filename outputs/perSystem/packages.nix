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
  key-cert-match = pkgs'.key-cert-match;
  llm = pkgs'.llm;
  mobileconfig = pkgs'.mobileconfig;
  nixverse = inputs'.nixverse.packages.nixverse;
  tailscale-utils = pkgs'.tailscale-utils.override { inherit buildGoModule; };
}
