{
  lib,
  pkgs,
  nodes,
  modules',
  config,
  ...
}:
{
  imports = [
    (modules'.fish { promptHostName = nodes.current.name != "hgl"; })
  ];
  xdg = {
    enable = true;
  };
  programs.ssh = {
    enable = true;
    controlMaster = "auto";
    controlPersist = "10m";
  };
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
      gpg = {
        format = "ssh";
      };
      user.signingkey = "~/.ssh/id_ed25519.pub";
    };
  };
  programs.nushell = {
    enable = true;
  };

  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    escapeTime = 5;
  };

  programs.neovim = {
    enable = true;
    extraConfig = ''
      set number relativenumber
    '';
  };

  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings = {
      keys = {
        normal = {
          "Cmd-s" = ":write";
        };
      };
    };
    languages = {
      language = [
        {
          name = "nix";
          auto-format = true;
          language-servers = [ "nil" ];
        }
      ];
      language-server.nil = {
        command = "nil";
        config = {
          formatting = {
            command = [ "nixfmt" ];
          };
        };
      };
    };
  };

  programs.vim = {
    enable = true;
  };

  programs.gh = {
    enable = true;
  };

  # programs.ghostty = {
  #   enable = true;
  #   settings = {
  #     font-family = "Monaco";
  #   };
  #   enableBashIntegration = true;
  #   enableFishIntegration = true;
  # };
  xdg.configFile =
    let
      keyValueSettings = {
        listsAsDuplicateKeys = true;
        mkKeyValue = lib.generators.mkKeyValueDefault { } " = ";
      };
      keyValue = pkgs.formats.keyValue keyValueSettings;
    in
    lib.mkMerge [
      {
        "ghostty/config" = {
          source = keyValue.generate "ghostty-config" {
            font-family = "Monaco";
            font-size = "12.5";
            theme = "nord";
            window-padding-x = "15";
            window-padding-y = "15";
            confirm-close-surface = false;
          };
        };
      }

      (lib.mapAttrs' (name: value: {
        name = "ghostty/themes/${name}";
        value.source = keyValue.generate "ghostty-${name}-theme" value;
      }) { })
    ];

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

  programs.go = {
    enable = true;
    package = pkgs.go_1_23;
    goPath = "Library/go";
  };

  home.sessionPath = [
    "$GOPATH/bin"
  ];

  home.sessionVariables = {
    PYTHONPYCACHEPREFIX = "${config.xdg.cacheHome}/pycache";
  };

  home.packages = with pkgs; [
    nil
    nixfmt-rfc-style
    shfmt
    shellcheck
    nodePackages.bash-language-server
    nodePackages.yaml-language-server
    remake # debug make
    dive # debug docker image
    vimgolf
    dig
    openssh
    jq
    unzip
    bashInteractive
    ripgrep
    rsync
    aider-chat
    claude-code
    pandoc
    woff2
    libwebp

    (parallel-full.override { willCite = true; })
    wget

    gopls
    delve
    go-tools

    nodejs_24
    nodePackages.pnpm

    coreutils
    curl
    openssl
    rsync
    # xterm-256color terminfo shipped by apple doesn't contain italic control
    # code, install this package gives a more complete xterm-256color terminfo
    ncurses

    android-tools
    oci-cli
    weechat

    gnumake
    gnutar
    iperf
  ];

  home.stateVersion = "24.11";
}
