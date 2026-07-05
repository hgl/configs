{ modules', ... }:
{
  imports = [
    modules'.rift
  ];
  services.rift = {
    enable = true;
    settings = {
      settings = {
        default_disable = false;
        mouse_follows_focus = false;
        focus_follows_mouse = false;
        hot_reload = true;
        layout = {
          mode = "scrolling";
        };
      };
      keys = {
        "Cmd + Option + Left" = {
          move_focus = "left";
        };
        "Cmd + Option + Right" = {
          move_focus = "right";
        };
      };
    };
  };
}
