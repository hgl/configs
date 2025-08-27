{
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    "${modulesPath}/profiles/minimal.nix"
  ];

  boot = {
    initrd.includeDefaultModules = false;
    loader = {
      timeout = 0;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  nix = {
    optimise = {
      automatic = true;
      persistent = true;
    };
    settings.trusted-users = [ "root" ];
  };

  time.timeZone = "Asia/Shanghai";

  users.mutableUsers = false;
  users.users.root = {
    shell = pkgs.fish;
  };
  programs.fish.enable = true;

  networking = {
    useDHCP = false;
    firewall.enable = false;
  };

  systemd.network = {
    enable = true;
    networks."99-default" = {
      matchConfig = {
        Name = "*";
      };
      networkConfig = {
        DHCP = true;
        MulticastDNS = true;
      };
    };
  };
  services.resolved = {
    enable = true;
    extraConfig = ''
      MulticastDNS=true
    '';
  };

  system.stateVersion = "24.05";
}
