{
  pkgs,
  pkgs',
  modules',
  ...
}:
{
  imports = [
    modules'.fish
  ];
  xdg = {
    enable = true;
  };
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        controlMaster = "auto";
        controlPersist = "10m";
        serverAliveInterval = 0;
        serverAliveCountMax = 3;
        controlPath = "~/.ssh/master-%r@%n:%p";
        sendEnv = [
          "COLORTERM"
          "TERM_PROGRAM"
          "TERM_PROGRAM_VERSION"
        ];
      };
    };
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    ignores = [
      ".DS_Store"
      ".vscode"
      "*.code-workspace"
      ".direnv"
    ];
    settings = {
      init.defaultBranch = "main";
      user = {
        name = "Glen Huang";
        signingkey = "~/.ssh/id_ed25519.pub";
      };
      push.autoSetupRemote = true;
    };
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

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    stdlib = ''
      declare -A direnv_layout_dirs
      direnv_layout_dir() {
        local hash
        hash=$(${pkgs.coreutils}/bin/sha1sum - <<< "$PWD" | ${pkgs.coreutils}/bin/head -c40)
        local path=''${PWD//[^a-zA-Z0-9]/-}
        local dir=''${XDG_CACHE_HOME:-$HOME/.cache}/direnv/layouts/$hash$path
        echo "''${direnv_layout_dirs[$PWD]:="$dir"}"
      }
    '';
  };

  programs.codex = {
    enable = true;
    package = pkgs'.codex;
  };

  programs.claude-code = {
    enable = true;
    package = pkgs'.claude-code;
  };

  programs.nushell = {
    enable = true;
  };

  programs.neovim = {
    enable = true;
    extraConfig = ''
      set number relativenumber
    '';
  };

  programs.vim = {
    enable = true;
  };

  home.packages = with pkgs; [
    pkgs'.serve
    pkgs'.init
    pkgs'.llm
    coreutils
    gnused
    gawk
    gnumake
    gnutar
    wget
    curl
    jq
    openssl
    rsync
    dig
    openssh
    bash
    ripgrep
    ffmpeg
    pstree
    iperf
    age
    awscli2
    gh
    lazygit
    yazi

    nil
    nixfmt
    shfmt
    shellcheck

    remake # debug make
    dive # debug docker image

    llama-cpp

    unzip
    cachix
    restic
    rclone
    delve
    vimgolf
    findutils

    # xterm-256color terminfo shipped by apple doesn't contain italic control
    # code, install this package gives a more complete xterm-256color terminfo
    ncurses

    android-tools
    oci-cli
    weechat
    mozjpeg
  ];

  home.stateVersion = "26.05";
}
