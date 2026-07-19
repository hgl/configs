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
  programs.fish.shellAliases =
    lib.mkIf
      (lib.elem nodes.current.name [
        "vm-nixos"
        "glen"
      ])
      {
        claude = "claude --dangerously-skip-permissions";
      };
}
