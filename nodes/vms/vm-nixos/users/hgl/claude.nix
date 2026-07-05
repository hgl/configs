{ pkgs', ... }: {
  programs.claude-code = {
    enable = true;
    package = pkgs'.claude-code;
  };
  programs.fish.shellAliases = {
    claude = "claude --dangerously-skip-permissions";
  };
}
