{
  pkgs,
  pkgs',
  nodes,
  config,
  ...
}:
let
  mkLink = config.lib.file.mkOutOfStoreSymlink;
  homeDir = "/Users/hgl/dev/configs/nodes/pcs/hgl/users/hgl";
in
{
  home.file = {
    ".hushlogin".text = "";
    ".config/sops".source = mkLink "${homeDir}/sops";
    ".config/emacs".source = mkLink "${homeDir}/emacs";
    ".config/karabiner/assets/complex_modifications".source = mkLink "${homeDir}/karabiner";
    "Library/Application Support/Code/User/settings.json".source =
      mkLink "${homeDir}/vscode/settings.json";
  };
  home.sessionPath = [
    "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
  ];

  programs.ssh = {
    enable = true;
    matchBlocks = {
      ${nodes.vm-nixos.name} = {
        user = "root";
        hostname = "${nodes.vm-nixos.name}.local";
        identityFile = "~/.ssh/id_ed25519.pub";
        identitiesOnly = true;
      };
    };
  };

  programs.git = {
    ignores = [
      ".DS_Store"
    ];
    extraConfig = {
      gpg = {
        ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      };
    };
  };

  home.shellAliases = {
    e = "${pkgs'.emacs}/bin/emacsclient";
  };

  home.packages = [
    pkgs.mkalias
    pkgs'.dnsclear
    pkgs'.serve
    pkgs'.init
  ];
}
