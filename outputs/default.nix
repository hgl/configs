{ flakeModules', ... }:
{
  imports = [
    flakeModules'.devShellPackages
  ];
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
}
