{ lib, pkgs, ... }:
{
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${lib.getExe pkgs.cage} -s -- ${lib.getExe pkgs.greetd.regreet}";
      user = "greeter";
    };
  };
  # services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
  # services.spice-webdavd.enable = true;

  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  environment.systemPackages = [
    # ... other packages
    pkgs.kitty # required for the default Hyprland config
  ];

}
