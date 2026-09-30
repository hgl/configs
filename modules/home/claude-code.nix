{
  lib,
  nodes,
  pkgs',
  ...
}:
{
  programs.claude-code = {
    enable = true;
    package = pkgs'.claude-code;
  };
  programs.fish.functions =
    lib.mkIf
      (lib.elem nodes.current.name [
        "vm-nixos"
        "pl-laptop"
      ])
      {
        claude = {
          wraps = "claude";
          body = ''
            # Resume commands can already contain these flags. Add only missing
            # defaults, and preserve an explicit request to disable Chrome.
            set -l defaults
            if not contains -- --chrome $argv; and not contains -- --no-chrome $argv
                set -a defaults --chrome
            end
            if not contains -- --dangerously-skip-permissions $argv
                set -a defaults --dangerously-skip-permissions
            end
            command claude $defaults $argv
          '';
        };
      };
}
