{ inputs' }:
inputs'.llm-agents.packages.agent-deck.overrideAttrs (old: {
  # The attach input filter otherwise swallows OSC 10/11 responses, leaving
  # Codex unable to detect the terminal's colors even after tmux attaches.
  patches = (old.patches or [ ]) ++ [ ./agent-deck-color-replies.patch ];
})
