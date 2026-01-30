{
  pkgs,
  inputs',
  ...
}:
{
  imports = [
    inputs'.vscode-server.modules.default
  ];

  services.vscode-server.enable = true;

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

  services.emacs = {
    enable = true;
    defaultEditor = true;
    client = {
      enable = true;
    };
  };

  programs.chromium = {
    enable = true;
    commandLineArgs = [
      "--ozone-platform=wayland"
    ];
  };
}
