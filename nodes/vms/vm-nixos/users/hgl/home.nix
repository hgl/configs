{
  pkgs,
  osConfig,
  config,
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
    enable = true;
    ignores = [
      ".vscode"
      "*.code-workspace"
      ".direnv"
    ];
    settings = {
      init.defaultBranch = "main";
      user = {
        name = "Glen Huang";
        email = "me@glenhuang.com";
      };
      push.autoSetupRemote = true;
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

  services.emacs = {
    enable = true;
    defaultEditor = true;
    client.enable = true;
  };

  home.packages = with pkgs; [
    config.services.emacs.package
    nerd-fonts.symbols-only
    btop
  ];

  programs.foot = {
    enable = true;
  };

  home.stateVersion = osConfig.system.stateVersion;
}
