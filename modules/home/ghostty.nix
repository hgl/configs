{
  programs.ghostty = {
    enable = true;
    package = null;
    settings = {
      font-family = "SF Mono";
      font-size = "13";
      theme = "nord";
      macos-option-as-alt = true;
      # Shift+Command-click must open links on this Mac even when a remote
      # Codex, Claude, or tmux session requests mouse events (XTSHIFTESCAPE).
      mouse-shift-capture = "never";
      window-padding-x = "15";
      window-padding-y = "15";
      confirm-close-surface = false;
      adjust-cell-height = -2;
      font-thicken = true;
    };
  };
}
