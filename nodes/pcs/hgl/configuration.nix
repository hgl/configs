{
  nodes,
  config,
  pkgs,
  modules',
  modulesPath,
  ...
}:
{
  disabledModules = [ "${modulesPath}/services/postgresql" ];
  imports = [
    modules'.postgresql
    modules'.emacs-macport
    ./utm.nix
    ./rift.nix
  ];

  nix = {
    optimise.automatic = true;
    settings = {
      extra-substituters = [ "https://hgl.cachix.org" ];
      extra-trusted-public-keys = [ "hgl.cachix.org-1:niFEnN9pxxWAvFsgbxCw9YaCdEfrDUV8wgWfS1HpK0M=" ];
    };
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
  };
  nixpkgs.config.allowUnfree = true;

  security.pam.services.sudo_local = {
    enable = true;
    touchIdAuth = true;
    reattach = true;
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_18_jit;
    authentication = ''
      local all all peer         map=main
      host  all all 127.0.0.1/32 scram-sha-256
      host  all all ::1/128      scram-sha-256
    '';
    identMap = ''
      main ${config.system.primaryUser} postgres
    '';
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
