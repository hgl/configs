{ nodes, inputs', ... }:
{
  imports = [
    inputs'.determinate.modules.default
    ./emacs.nix
  ];
  nixpkgs = {
    hostPlatform = "aarch64-darwin";
  };
  nix = {
    enable = false;
  };
  determinate-nix.customSettings = {
    extra-substituters = [ "https://hgl.cachix.org" ];
    extra-trusted-public-keys = [ "hgl.cachix.org-1:niFEnN9pxxWAvFsgbxCw9YaCdEfrDUV8wgWfS1HpK0M=" ];
    eval-cores = 0;
  };

  security.pam.services.sudo_local = {
    enable = true;
    touchIdAuth = true;
    reattach = true;
  };

  users.users = {
    hgl.home = "/Users/hgl";
    root.home = "/var/root";
  };

  networking = {
    computerName = "Glen’s Laptop";
  };

  system.stateVersion = 4;
}
