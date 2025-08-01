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

  virtualisation.rosetta.enable = true;

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
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMFTNE97QDW/v8PgMZoZz7kalVJUKVyI7eypqJuUrkos root"
    ];
  };
  programs.fish = {
    enable = true;
  };
  environment.shells = with pkgs; [
    fish
  ];

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
