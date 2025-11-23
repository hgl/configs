{ lib, pkgs, ... }:
{
  hardware.graphics.enable = true;
  programs.regreet = {
    enable = true;
  };
  services.greetd.settings = {
    default_session.user = "hgl";
    initial_session = {
      command = lib.getExe pkgs.hyprland;
      user = "hgl";
    };
  };
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };
}
