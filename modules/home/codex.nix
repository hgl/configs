{
  lib,
  nodes,
  pkgs',
  ...
}:
{
  programs.codex = {
    enable = true;
    package = pkgs'.codex;
  };
  programs.fish.shellAliases =
    lib.mkIf
      (lib.elem nodes.current.name [
        "vm-nixos"
        "glen"
      ])
      {
        codex = "codex --yolo";
      };
}
