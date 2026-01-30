{
  pkgs,
  pkgs',
  modules',
  nodes,
  config,
  ...
}:
let
  mkLink = config.lib.file.mkOutOfStoreSymlink;
  homeDir = "/Users/hgl/dev/configs/nodes/pcs/hgl/users/hgl";
in
{
  imports = [
    modules'.go
    modules'.node
    modules'.python
    ./emacs
  ];
  home.file = {
    ".hushlogin".text = "";
    ".config/sops".source = mkLink "${homeDir}/sops";
    ".config/karabiner/assets/complex_modifications".source = mkLink "${homeDir}/karabiner";
    "Library/Application Support/Code/User/settings.json".source =
      mkLink "${homeDir}/vscode/settings.json";
  };
  home.sessionPath = [
    "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
  ];

  programs.ssh = {
    matchBlocks = {
      ${nodes.vm-nixos.name} = {
        user = "root";
      };
      ${nodes.hgl2.name} = {
        user = "hgl";
      };
    };
  };

  programs.git = {
    ignores = [
      ".DS_Store"
    ];
    settings = {
      gpg = {
        ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      };
    };
  };

  programs.ghostty = {
    enable = true;
    package = null;
    settings = {
      font-family = "Monaco";
      font-size = "12.5";
      theme = "nord";
      window-padding-x = "15";
      window-padding-y = "15";
      confirm-close-surface = false;
      adjust-cell-height = -2;
      font-thicken = true;
    };
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

  home.shellAliases = {
    e = "emacsclient";
  };

  home.packages = [
    pkgs.mkalias
    pkgs'.dnsclear
    pkgs'.serve
    pkgs'.init
    pkgs.remake # debug make
    pkgs.dive # debug docker image

    pkgs.aider-chat
    pkgs.claude-code
    pkgs.gemini-cli
    pkgs.codex
    pkgs.pandoc
    pkgs.woff2
    pkgs.libwebp
    pkgs.unzip
    pkgs.cachix
    pkgs.restic
    pkgs.rclone
    pkgs.delve
    pkgs.vimgolf
    pkgs.findutils

    (pkgs.parallel-full.override { willCite = true; })
    # xterm-256color terminfo shipped by apple doesn't contain italic control
    # code, install this package gives a more complete xterm-256color terminfo
    pkgs.ncurses

    pkgs.android-tools
    pkgs.oci-cli
    pkgs.weechat
  ];
}
