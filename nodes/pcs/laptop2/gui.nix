{ lib, pkgs, nodes, ... }:
{
  hardware.graphics.enable = true;
  programs.regreet = {
    enable = true;
  };
  services.greetd.settings = {
    default_session.user = nodes.current.users.main.name;
    initial_session = {
      command = lib.getExe pkgs.hyprland;
      user = nodes.current.users.main.name;
    };
  };
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };
}
