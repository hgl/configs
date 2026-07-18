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
  home.file.".ssh/id_hgl.pub".text =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICezYVapRivfpiaxOFG09uty365vyGDqXSGfFKvB54yG";

  programs.ssh = {
    settings = {
      "github-hgl" = {
        HostName = "github.com";
        User = "git";
        IdentityFile = "~/.ssh/id_hgl.pub";
        IdentitiesOnly = true;
        IdentityAgent = lib.toJSON "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
      };
    };
  };

  home.packages = with pkgs; [
    pkgs'.slack-cli-darwin
    pkgs'.dnsclear
  ];
}
