{ config, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false;
    settings = {
      bind = [
        "SUPER, Q, killactive"
        "SUPER, Return, exec, foot"
        "SUPER, Space, exec, rofi -show drun"
      ];
    };
  };

  programs.foot = {
    enable = true;
  };

  programs.rofi = {
    enable = true;
    terminal = toString config.programs.foot.package;
    cycle = true;
  };
}
