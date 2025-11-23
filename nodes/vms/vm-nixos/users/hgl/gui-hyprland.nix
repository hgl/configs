{
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      bind = [
        "SUPER, Q, killactive"
        "SUPER, Return, exec, foot"
      ];
    };
  };

  programs.foot = {
    enable = true;
  };
}
