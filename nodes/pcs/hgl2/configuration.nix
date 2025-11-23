{ modules', ... }:
{
  imports = [
    (modules'.virt-manager { user = "hgl"; })
    ./gui.nix
  ];
  boot = {
    loader = {
      timeout = 0;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };
  hardware.graphics.enable = true;
  nixpkgs.config.allowUnfree = true;

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

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "hgl" ];
  };

  # services.fprintd = {
  #   enable = true;
  #   tod = {
  #     enable = true;
  #     driver = pkgs.libfprint-2-tod1-goodix-550a;
  #   };
  # };

  system.stateVersion = "24.11";
}
