{
  lib,
  pkgs,
  pkgs',
  modules',
  nodes,
  ...
}:
{
  imports = [
    modules'.sopsAgeKeys
    modules'.go
    modules'.node
    modules'.python
    modules'.karabiner
    modules'.emacs-macport
    modules'.vscode
    modules'.paneru
    modules'.ghostty
  ];
  home.file = {
    ".hushlogin".text = "";
    ".ssh/id_ed25519.pub".text =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICezYVapRivfpiaxOFG09uty365vyGDqXSGfFKvB54yG";
  };

  programs.ssh = {
    settings = {
      ${nodes.vm-nixos.name} = {
        HostName = "${nodes.vm-nixos.name}.local";
        User = "hgl";
        IdentityFile = "~/.ssh/id_ed25519.pub";
        IdentitiesOnly = true;
      };
      "*" = {
        IdentityAgent = lib.toJSON "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
      };
    };
  };

  home.packages = with pkgs; [
    pkgs'.slack-cli-darwin
    pkgs'.dnsclear
    mkalias
    tio
  ];
}
