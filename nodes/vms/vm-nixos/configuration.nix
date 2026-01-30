{ pkgs, ... }:
{
  imports = [
    ./utm-vf.nix
    ./gui-greetd.nix
    ./gui-hyprland.nix
  ];
  boot = {
    loader = {
      timeout = 0;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    optimise = {
      automatic = true;
      persistent = true;
    };
    settings.trusted-users = [ "root" ];
  };

  time.timeZone = "Asia/Shanghai";

  users.mutableUsers = false;
  users.users = {
    root = {
      shell = pkgs.fish;
    };
    hgl = {
      isNormalUser = true;
      shell = pkgs.fish;
      extraGroups = [ "wheel" ];
      hashedPassword = "$y$j9T$6SctxtQXGdvDNL3I2l/NA0$O..svrSGZtmzyQ9D2f9KRh.J28tT096OV4dgOYaiPX1";
    };
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

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  documentation.enable = false;
  environment.systemPackages = with pkgs; [
  ];

  system.stateVersion = "24.05";
}
