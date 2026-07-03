{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.services.rift;
  format = pkgs.formats.toml { };
  settingsFile = format.generate "config.toml" (
    lib.filterAttrsRecursive (n: v: v != null && v != { }) {
      settings = cfg.settings // {
        layout = cfg.layout;
        ui = cfg.ui;
        gestures = cfg.gestures;
        window_snapping = cfg.windowSnapping;
      };
      virtual_workspaces = cfg.virtualWorkspaces;
      app_rules = cfg.appRules;
      modifier_combinations = cfg.modifierCombinations;
      keys = cfg.keybindings;
    }
  );
in
{
  options.services.rift = {
    enable = lib.mkEnableOption "Rift - A tiling window manager for macOS";

    package = lib.mkOption {
      type = lib.types.package;
      description = "The rift package to use.";
    };

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Rift settings configuration.";
      example = lib.literalExpression ''
        {
          animate = false;
          animation_duration = 0.3;
          animation_fps = 100.0;
          focus_follows_mouse = true;
          mouse_follows_focus = true;
          mouse_hides_on_focus = true;
          auto_focus_blacklist = [];
          hot_reload = true;
          run_on_start = [];
        }
      '';
    };

    layout = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Layout configuration.";
      example = lib.literalExpression ''
        {
          mode = "traditional";
          master_stack = {
            master_ratio = 0.6;
            master_count = 1;
            master_side = "left";
            new_window_placement = "master";
          };
          gaps = {
            outer = { top = 0; left = 0; bottom = 0; right = 0; };
            inner = { horizontal = 0; vertical = 0; };
            per_display = {};
          };
        }
      '';
    };

    ui = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "UI configuration (menu bar, stack line, mission control).";
      example = lib.literalExpression ''
        {
          menu_bar = {
            enabled = false;
            show_empty = false;
            mode = "all";
            active_label = "index";
            display_style = "layout";
          };
          stack_line = {
            enabled = false;
            horiz_placement = "top";
            vert_placement = "left";
            thickness = 20.0;
            spacing = 1.0;
          };
          mission_control = {
            enabled = false;
            fade_enabled = false;
            fade_duration_ms = 180.0;
          };
        }
      '';
    };

    gestures = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Trackpad gestures configuration.";
      example = lib.literalExpression ''
        {
          enabled = false;
          invert_horizontal_swipe = false;
          swipe_vertical_tolerance = 0.4;
          skip_empty = true;
          fingers = 3;
          distance_pct = 0.08;
          haptics_enabled = true;
          haptic_pattern = "level_change";
        }
      '';
    };

    windowSnapping = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Window snapping configuration.";
      example = lib.literalExpression ''
        {
          drag_swap_fraction = 0.3;
        }
      '';
    };

    virtualWorkspaces = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Virtual workspaces configuration.";
      example = lib.literalExpression ''
        {
          enabled = true;
          default_workspace_count = 4;
          auto_assign_windows = true;
          preserve_focus_per_workspace = true;
          workspace_auto_back_and_forth = false;
          reapply_app_rules_on_title_change = false;
          workspace_rules = [
            { workspace = 1; layout = "bsp"; }
            { workspace = "dev"; layout = "scrolling"; }
          ];
          workspace_names = [ "main" "dev" "browser" "media" ];
        }
      '';
    };

    appRules = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [ ];
      description = "Application rules for automatic window assignment.";
      example = lib.literalExpression ''
        [
          { app_id = "com.apple.Safari"; workspace = 2; }
          { title_substring = "Preferences"; floating = true; }
          { app_name = "Calendar"; workspace = 3; floating = true; }
          { app_id = "com.example.X"; ax_subrole = "AXDialog"; floating = true; }
        ]
      '';
    };

    modifierCombinations = lib.mkOption {
      type = lib.types.attrs;
      default = {
        comb1 = "Alt + Shift";
      };
      description = "Named modifier combinations for reuse in keybindings.";
      example = lib.literalExpression ''
        {
          comb1 = "Alt + Shift";
          comb2 = "Ctrl + Shift";
        }
      '';
    };

    keybindings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Key bindings for rift commands.";
      example = lib.literalExpression ''
        {
          "Alt + H" = { move_focus = "left"; };
          "Alt + J" = { move_focus = "down"; };
          "Alt + K" = { move_focus = "up"; };
          "Alt + L" = { move_focus = "right"; };
          "Alt + 1" = { switch_to_workspace = 1; };
          "Alt + 0" = { switch_to_workspace = 0; };
          "Alt + Tab" = "switch_to_last_workspace";
        }
      '';
    };

    configFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Optional path to a custom config file. Overrides generated config.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."rift/config.toml".source = settingsFile;

    launchd.user.agents.rift = {
      path = [ "${cfg.package}/bin" ];
      serviceConfig = {
        ProgramArguments = [ "${cfg.package}/bin/rift" ];
        RunAtLoad = true;
        KeepAlive = true;
        StandardOutPath = "/tmp/rift.log";
        StandardErrorPath = "/tmp/rift.log";
      };
    };

    system.defaults.CustomUserPreferences."com.ryanmacanth.Rift" = {
      ConfigPath = "/etc/rift/config.toml";
    };
  };
}
