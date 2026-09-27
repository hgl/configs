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
          gaps = {
            inner = {
              horizontal = 10;
              vertical = 10;
            };
          };
        };
      };
      keys = {
        "Cmd + Option + K" = {
          move_focus = "up";
        };
        "Cmd + Option + J" = {
          move_focus = "down";
        };
        "Cmd + Option + H" = {
          move_focus = "left";
        };
        "Cmd + Option + L" = {
          move_focus = "right";
        };
        "Cmd + Option + Shift + K" = {
          move_node = "up";
        };
        "Cmd + Option + Shift + J" = {
          move_node = "down";
        };
        "Cmd + Option + Shift + H" = {
          move_node = "left";
        };
        "Cmd + Option + Shift + L" = {
          move_node = "right";
        };
        "Cmd + Option + Delete" = {
          toggle_space_activated = true;
        };
      };
    };
  };
}
