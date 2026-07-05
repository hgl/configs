{ inputs', ... }: {
  imports = [
    inputs'.paneru.modules.paneru
  ];

  services.paneru = {
    enable = true;
    settings = {
      options = {
        animation_speed = 20;
        focus_follows_mouse = false;
        mouse_follows_focus = false;
        horizontal_mouse_warp = -1;
        preset_column_widths = [
          0.33
          0.5
          0.66
          1
        ];
      };
      padding = {
        top = 5;
        bottom = 5;
        left = 5;
        right = 5;
      };
      decorations = {
        workspace_menu_status = false;
        active.border = {
          enabled = true;
          color = "#26f7f0";
          width = 4;
        };
      };
      windows = {
        all = {
          title = ".*";
          width = 0.5;
          horizontal_padding = 5;
          vertical_padding = 5;
        };
        ghostty = {
          title = ".*";
          bundle_id = "com.mitchellh.ghostty";
          width = 0.33;
        };
      };
      bindings = {
        window_focus_west = "cmd + alt - h";
        window_focus_east = "cmd + alt - l";
        window_focus_north = "cmd + alt - k";
        window_focus_south = "cmd + alt - j";
        window_resize = "cmd + alt + shift - return";
        window_center = "cmd + alt - return";
        window_swap_west = "cmd + alt + shift - h";
        window_swap_east = "cmd + alt + shift - l";
        window_stack = "cmd + alt - s";
        window_unstack = "cmd + alt + shift - s";
        window_nextdisplay = "cmd + alt - tab";
        window_manage = "cmd + alt - space";
        window_virtualnum_1 = "cmd + alt - 1";
        window_virtualmovenum_1 = "cmd + alt + shift - 1";
        window_virtualnum_2 = "cmd + alt - 2";
        window_virtualmovenum_2 = "cmd + alt + shift - 2";
      };
    };
  };
}
