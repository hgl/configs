{
  pkgs,
  osConfig,
  modules',
  pkgs',
  nodes,
  ...
}:
{
  imports = [
    modules'.fish
  ];
  xdg = {
    enable = true;
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
        email = "me@glenhuang.com";
      };
      push.autoSetupRemote = true;
    };
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
      };
      "hgl" = {
        hostname = "${nodes.hgl.name}.local";
        user = "hgl";
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
  programs.fish.shellAliases = {
    claude = "claude --dangerously-skip-permissions";
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

  home.packages = with pkgs; [
    pkgs'.vercel
    pkgs'.zmx
    lazygit
    nil
    awscli2
    gh
    ripgrep
    jq
    dig
    openssl
    hcloud
    tuicr
    yazi
  ];

  home.stateVersion = osConfig.system.stateVersion;
}
