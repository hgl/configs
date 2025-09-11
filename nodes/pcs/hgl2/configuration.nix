{
  lib,
  pkgs,
  ...
}:
{
  boot = {
    loader = {
      timeout = 0;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  nix = {
    optimise.automatic = true;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  users = {
    mutableUsers = false;
    users = {
      hgl = {
        isNormalUser = true;
        home = "/home/hgl";
        group = "hgl";
        extraGroups = [ "wheel" ];
      };
    };
    groups.hgl = { };
  };

  security.sudo = {
    enable = true;
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  networking = {
    useDHCP = false;
    firewall.enable = false;
    wireless = {
      enable = true;
    };
  };

  systemd.network = {
    enable = true;
    networks."99-default" = {
      matchConfig = {
        Name = "*";
      };
      networkConfig = {
        DHCP = true;
      };
    };
  };

  security.polkit.enable = true;
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${lib.getExe pkgs.cage} -s -- ${lib.getExe pkgs.greetd.regreet}";
      user = "greeter";
    };
  };
  programs.regreet = {
    enable = true;
  };
  services.fprintd = {
    enable = true;
    tod = {
      enable = true;
      driver = pkgs.libfprint-2-tod1-goodix-550a;
    };
  };
  programs.uwsm = {
    enable = true;
    waylandCompositors.sway = {
      prettyName = "Sway";
      comment = "Sway";
      binPath = lib.getExe pkgs.sway;
    };
  };
  security.pam.services.swaylock.fprintAuth = true;
  environment.systemPackages = with pkgs; [
    nextcloud-client
  ];
  system.stateVersion = "24.11";
}
