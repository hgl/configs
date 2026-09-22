{
  lib,
  pkgs,
  pkgs',
  modules',
  ...
}:
{
  imports = [
    modules'.node
    modules'.python
    modules'.karabiner
    modules'.emacs-macport
    modules'.vscode
    modules'.paneru
  ];
  home.file = {
    ".hushlogin".text = "";
  };

  programs.ssh = {
    settings = {
      "github-hgl" = {
        HostName = "github.com";
        User = "git";
        IdentityFile = "~/.ssh/id_hgl.pub";
        IdentityAgent = lib.toJSON "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
        IdentitiesOnly = true;
      };
    };
  };

  home.packages = with pkgs; [
    pkgs'.slack-cli-darwin
    pkgs'.dnsclear
  ];
}
