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

}
//
  lib.optional
    (lib.elem nodes.current.name [
      "vm-nixos"
      "glen"
    ])
    {
      programs.fish.shellAliases = {
        codex = "codex --yolo";
      };
    }
