{ pkgs, ... }:
{
  wayland.windowManager.sway = {
    enable = true;
    config = {
      modifier = "Mod4";
      terminal = "foot";
      startup = [
        { command = "foot"; }
        {
          command = "waybar";
          always = true;
        }
      ];
    };
  };

  programs.waybar.enable = true;

  home.packages = with pkgs; [
    foot
    _1password-gui
    usbutils
    pciutils
  ];

  programs.chromium = {
    enable = true;
    commandLineArgs = [
      "--ozone-platform=wayland"
    ];
  };
}
