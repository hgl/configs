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
    settings = {
      ${nodes.vm-nixos.name} = {
        hostname = "${nodes.vm-nixos.name}.local";
        user = "hgl";
      };
    };
  };

  programs.git = {
    settings = {
      gpg = {
        format = "ssh";
        ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      };
    };
  };

  programs.ghostty = {
    enable = true;
    package = null;
    settings = {
      font-family = "SF Mono";
      font-size = "13";
      theme = "nord";
      window-padding-x = "15";
      window-padding-y = "15";
      confirm-close-surface = false;
      adjust-cell-height = -2;
      font-thicken = true;
    };
  };

  home.shellAliases = {
    e = "emacsclient";
  };

  home.packages = with pkgs; [
    pkgs'.slack-cli-darwin
    pkgs'.dnsclear
    mkalias
    tio
  ];
}
