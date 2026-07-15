{ pkgs', ... }: {
  programs.codex = {
    enable = true;
    package = pkgs'.codex;
  };

  programs.fish.shellAliases = {
    codex = "codex --yolo";
  };
}
