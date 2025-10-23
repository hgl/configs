{ nodes, ... }:
{
  imports = [
    ./emacs.nix
  ];
  nixpkgs = {
    hostPlatform = "aarch64-darwin";
  };
  nix = {
    optimise.automatic = true;
    settings = {
      extra-substituters = [ "https://hgl.cachix.org" ];
      extra-trusted-public-keys = [ "hgl.cachix.org-1:niFEnN9pxxWAvFsgbxCw9YaCdEfrDUV8wgWfS1HpK0M=" ];
    };
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "${nodes.vm-nixos-builder.name}.local";
        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];
      }
    ];
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

  system.primaryUser = "hgl";

  system.stateVersion = 6;
}
