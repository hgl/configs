{ pkgs, ... }:
{
  imports = [
    ./x.nix
  ];
  boot = {
    loader = {
      timeout = 0;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };
  virtualisation.vmware.guest.enable = true;
  # virtualisation.rosetta.enable = true;
  # services.spice-vdagentd.enable = true;

  nix = {
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
    firewall.enable = false;
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  documentation.enable = false;
  environment.systemPackages = with pkgs; [
    ghostty
    vulkan-tools
    virtualglLib
  ];

  system.fsPackages = [ pkgs.open-vm-tools ];

  fileSystems."/home/hgl/dev" = {
    device = ".host:/dev";
    fsType = "fuse./run/current-system/sw/bin/vmhgfs-fuse";
    options = [
      "umask=22"
      "uid=1000"
      "gid=100"
      "allow_other"
      "defaults"
      "auto_unmount"
    ];
  };

  system.stateVersion = "24.05";
}
