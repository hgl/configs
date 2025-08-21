{ nodes, ... }:
{
  imports = [
    ./virby.nix
    ./emacs.nix
  ];
  nixpkgs = {
    hostPlatform = "aarch64-darwin";
  };
  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "${nodes.vm-nixos.name}.local";
        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];
      }
    ];
    settings = {
      extra-substituters = [ "https://hgl.cachix.org" ];
      extra-trusted-public-keys = [ "hgl.cachix.org-1:niFEnN9pxxWAvFsgbxCw9YaCdEfrDUV8wgWfS1HpK0M=" ];
    };
  };
  ids.gids.nixbld = 350;

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
