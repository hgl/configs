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

    # Two tool-scoped groups so the quick-create key has a per-tool cursor
    # position: on a group header it takes the tool from that group's most
    # recent session. No default_path — it would have to differ per machine, so
    # the path falls back to the cursor's session, then the launch cwd.
    [groups."claude"]
    create = true

    [groups."codex"]
    create = true

    [hotkeys]
    # Swap n/N so the plain key is the auto-named one that never prompts for a
    # name. `n` quick-creates (inheriting tool/path/options from the cursor),
    # `N` opens the full dialog when a field needs setting explicitly.
    new_session = "N"
    quick_create = "n"
  '';
in
{
  home.packages = [
    pkgs'.agent-deck
    # Every session is a tmux session named agentdeck_*; agent-deck shells out to
    # tmux instead of linking it, so it has to be on PATH.
    pkgs.tmux
  ];

  # Quick-create straight from the shell, bypassing the deck. -Q auto-names the
  # session (suppressed by --title), --attach starts it and drops you in. Add
  # --model / --effort / --account here to pin per-alias defaults; the in-TUI
  # quick create can only inherit them from the cursor.
  programs.fish.shellAliases = {
    ad = "agent-deck";
    ad-claude = "agent-deck add -Q -c claude --attach";
    ad-codex = "agent-deck add -Q -c codex --attach";
  };

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
