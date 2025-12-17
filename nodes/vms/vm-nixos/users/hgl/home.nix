{
  pkgs,
  osConfig,
  modules',
  ...
}:
{
  imports = [
    modules'.fish
    ./gui-hyprland.nix
  ];
  xdg = {
    enable = true;
  };
  programs.firefox.enable = true;
  programs.git = {
    userName = "Glen Huang";
    enable = true;
    userEmail = "me@glenhuang.com";
    ignores = [
      ".vscode"
      "*.code-workspace"
      ".direnv"
    ];
    extraConfig = {
      init.defaultBranch = "main";
    };
  };

  # programs.rofi = {
  #   enable = true;
  # };
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    stdlib = ''
      declare -A direnv_layout_dirs
      direnv_layout_dir() {
        local hash
        hash=$(sha1sum - <<< "$PWD" | head -c40)
        local path=''${PWD//[^a-zA-Z0-9]/-}
        local dir=''${XDG_CACHE_HOME:-$HOME/.cache}/direnv/layouts/$hash$path
        echo "''${direnv_layout_dirs[$PWD]:="$dir"}"
      }
    '';
  };

  home.packages = with pkgs; [

  ];

  programs.foot = {
    enable = true;
  };

  home.stateVersion = osConfig.system.stateVersion;
}
