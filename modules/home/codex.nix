{
  pkgs',
  ...
}:
{
  programs.codex = {
    enable = true;
    package = pkgs'.codex;
  };
  programs.fish.shellAliases.codex = "codex --yolo --no-daemon";

  # Agent Deck execs Codex directly, bypassing the interactive shell alias.
  # Apply these defaults on every host, including local and remote sessions.
  programs.agent-deck.codexArgs = [ "--no-daemon" ];
  programs.agent-deck.settings.codex.yolo_mode = true;
}
