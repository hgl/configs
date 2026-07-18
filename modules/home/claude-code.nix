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
}
//
  lib.optionalAttrs
    (lib.elem nodes.current.name [
      "vm-nixos"
      "glen"
    ])
    {
      programs.fish.shellAliases = {
        claude = "claude --dangerously-skip-permissions";
      };
    }
