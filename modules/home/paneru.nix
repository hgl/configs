{ inputs', pkgs', ... }: {
  imports = [
    inputs'.paneru.modules.paneru
  ];

  services.paneru = {
    enable = true;
    package = pkgs'.paneru;
    settings = {
      options = {
        focus_follows_mouse = false;
        mouse_follows_focus = false;
        horizontal_mouse_warp = -1;
        preset_column_widths = [
          0.33
          0.66
          1
        ];
      };
      padding = {
        top = 0;
        bottom = 0;
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
        onepassword-touchid = {
          title = "1Password";
          bundle_id = "com.1password.1password";
          floating = true;
        };
      };
      bindings = {
        window_focus_west = "cmd + alt - h";
        window_focus_east = "cmd + alt - l";
        window_focus_north = "cmd + alt - k";
        window_focus_south = "cmd + alt - j";
        window_resize = "cmd + alt - space";
        window_center = "cmd + alt - return";
        window_swap_west = "cmd + alt + shift - h";
        window_swap_east = "cmd + alt + shift - l";
        window_swap_north = "cmd + alt + shift - k";
        window_swap_south = "cmd + alt + shift - j";
        window_stack = "cmd + alt - s";
        window_unstack = "cmd + alt + shift - s";
        window_nextdisplay = "cmd + alt - tab";
        window_manage = "cmd + alt - delete";
        window_virtualnum_1 = "cmd + alt - 1";
        window_virtualmovenum_1 = "cmd + alt + shift - 1";
        window_virtualnum_2 = "cmd + alt - 2";
        window_virtualmovenum_2 = "cmd + alt + shift - 2";
      };
    };
  };
}
