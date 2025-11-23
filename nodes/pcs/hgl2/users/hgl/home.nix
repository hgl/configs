{
  pkgs,
  ...
}:
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

  home.packages = with pkgs; [
    usbutils
    pciutils
  ];

  programs.foot = {
    enable = true;
  };

  programs.chromium = {
    enable = true;
    commandLineArgs = [
      "--ozone-platform=wayland"
    ];
  };
}
