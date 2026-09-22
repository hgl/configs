{
  config,
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
    # Ghostty only sets TERMINFO for shells it spawns, so ssh logins can't find
    # xterm-ghostty without this.
    ".terminfo".source =
      config.lib.file.mkOutOfStoreSymlink "/Applications/Ghostty.app/Contents/Resources/terminfo";
  };

  programs.ssh = {
    settings = {
      # Inside an ssh login, use the forwarded agent. ssh keeps the first
      # IdentityAgent it sees, so order this before every other block ("*" is
      # always last).
      forwarded-agent =
        lib.hm.dag.entryBefore
          (lib.attrNames (
            lib.removeAttrs config.programs.ssh.settings [
              "forwarded-agent"
              "*"
            ]
          ))
          {
            header = ''Match exec "printenv SSH_CONNECTION"'';
            IdentityAgent = "SSH_AUTH_SOCK";
          };
      "*" = {
        IdentityAgent = lib.toJSON "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
      };
    };
  };

  home.packages = with pkgs; [
    pkgs'.slack-cli-darwin
    pkgs'.dnsclear
  ];
}
