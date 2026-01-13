{
  pkgs,
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
        hash=$(sha1sum - <<< "$PWD" | head -c40)
        local path=''${PWD//[^a-zA-Z0-9]/-}
        local dir=''${XDG_CACHE_HOME:-$HOME/.cache}/direnv/layouts/$hash$path
        echo "''${direnv_layout_dirs[$PWD]:="$dir"}"
      }
    '';
  };

  # services.syncthing = {
  #   enable = true;
  # };

  home.packages = [
    pkgs.coreutils
    pkgs.gnused
    pkgs.gawk
    pkgs.gnumake
    pkgs.gnutar
    pkgs.wget
    pkgs.curl
    pkgs.jq
    pkgs.openssl
    pkgs.rsync
    pkgs.dig
    pkgs.openssh
    pkgs.bash
    pkgs.ripgrep
    pkgs.ffmpeg
    pkgs.pstree
    pkgs.iperf
    pkgs.age

    pkgs.nil
    pkgs.nixfmt-rfc-style
    pkgs.shfmt
    pkgs.shellcheck
  ];

  home.stateVersion = "24.11";
}
