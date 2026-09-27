{
  config,
  lib,
  pkgs,
  pkgs',
  ...
}:
let
  configDir = "${config.xdg.configHome}/agent-deck";
  configFile = "${configDir}/config.toml";
  # Seeded on first activation only, see below.
  seedConfig = pkgs.writeText "agent-deck-config.toml" ''
    [tmux]
    # Host sessions on their own tmux server (tmux -L agent-deck) so agent-deck's
    # bind-key, set-option and status line mutations stay off the default server.
    # Each session records this at creation time and is never migrated, so it has
    # to be set before the first session exists.
    socket_name = "agent-deck"

    [fork]
    # Make `f` branch the conversation only. The defaults also cut a worktree and
    # branch per fork, which is the wrong unit for following up on an answer.
    # Turn them back on for a single fork from the Shift+F dialog.
    worktree = false
    with_state = false
    docker = "off"
  '';
in
{
  home.packages = [
    pkgs'.agent-deck
    # Every session is a tmux session named agentdeck_*; agent-deck shells out to
    # tmux instead of linking it, so it has to be on PATH.
    pkgs.tmux
  ];

  # agent-deck owns config.toml at runtime: the TUI settings view and the config
  # migrations both rewrite it via os.WriteFile(path, …, 0600). Managing it with
  # xdg.configFile would point it at a read-only store path and break both, so
  # seed it once and leave the file writable afterwards.
  home.activation.agentDeckConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -e ${lib.escapeShellArg configFile} ]; then
      run mkdir -p ${lib.escapeShellArg configDir}
      run install -m 600 ${seedConfig} ${lib.escapeShellArg configFile}
    fi
  '';
}
