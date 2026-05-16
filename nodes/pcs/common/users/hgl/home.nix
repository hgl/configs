{
  pkgs,
  pkgs',
  modules',
  inputs',
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
    matchBlocks = {
      "*" = {
        controlMaster = "auto";
        controlPersist = "10m";
        serverAliveInterval = 0;
        serverAliveCountMax = 3;
        controlPath = "~/.ssh/master-%r@%n:%p";
      };
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519.pub";
        identitiesOnly = true;
      };
    };
  };
  home.file.".ssh/id_ed25519.pub".text =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICezYVapRivfpiaxOFG09uty365vyGDqXSGfFKvB54yG";

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
        signingkey = "~/.ssh/id_ed25519.pub";
      };
      gpg = {
        format = "ssh";
      };
      push.autoSetupRemote = true;
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
    package = inputs'.llm-agents.packages.codex;
  };

  # services.syncthing = {
  #   enable = true;
  # };

  home.packages =
    with pkgs';
    [
      serve
      init
    ]
    ++ (with pkgs; [
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
      pkgs'.vercel
      awscli2
      gh
      lazygit

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

      (parallel-full.override { willCite = true; })
      # xterm-256color terminfo shipped by apple doesn't contain italic control
      # code, install this package gives a more complete xterm-256color terminfo
      ncurses

      android-tools
      oci-cli
      weechat
      mozjpeg
    ])
    ++ (with inputs'.llm-agents.packages; [
      claude-code
    ]);

  home.stateVersion = "26.05";
}
