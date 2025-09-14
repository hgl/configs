{ pkgs, ... }:
{
  hardware.graphics.enable = true;
  services.xserver = {
    enable = true;
    excludePackages = [ pkgs.xterm ];
  };
  services.displayManager = {
    gdm.enable = true;
    defaultSession = "gnome";
    autoLogin = {
      enable = true;
      user = "hgl";
    };
  };
  services.desktopManager.gnome.enable = true;

  services.gnome.core-apps.enable = false;
  services.gnome.core-developer-tools.enable = false;
  services.gnome.games.enable = false;
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    gnome-user-docs
  ];

  # Disable screen lock
  programs.dconf.profiles.user.databases = [
    {
      settings = {
        "org/gnome/desktop/screensaver" = {
          lock-enabled = false;
        };
      };
    }
  ];
}
