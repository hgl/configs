{
  config,
  lib,
  pkgs,
  pkgs',
  ...
}:
let
  cfg = config.programs.agent-deck;
  tomlFormat = pkgs.formats.toml { };
  configSource = tomlFormat.generate "agent-deck-config.toml" cfg.settings;
in
{
  options.programs.agent-deck.settings = lib.mkOption {
    type = tomlFormat.type;
    default = { };
    description = ''
      Contents of agent-deck's config.toml. The defaults are set below; a node
      merges its own entries over them, which is how settings that must stay
      out of this public tree get in — the [remotes] hosts, from private/.
    '';
  };

  config = {
    programs.agent-deck.settings = {
      tmux = {
        # Host sessions on their own tmux server (tmux -L agent-deck) so agent-deck's
        # bind-key, set-option and status line mutations stay off the default server.
        # Each session records this at creation time and is never migrated, so it has
        # to be set before the first session exists.
        socket_name = "agent-deck";
      };

      instances = {
        # Let a second agent-deck open on the same profile, so the deck can be up
        # in more than one terminal at a time. Upstream defaults this off because
        # two instances each run the reviver, which used to restart and tear down
        # each other's live sessions. Only the first instance to start (the
        # primary) owns the notification bar; the rest are otherwise equal.
        allow_multiple = true;
      };

      fork = {
        # Make `f` branch the conversation only. The defaults also cut a worktree and
        # branch per fork, which is the wrong unit for following up on an answer.
        # Turn them back on for a single fork from the Shift+F dialog.
        worktree = false;
        with_state = false;
        docker = "off";
      };

      display = {
        # Drop the "[<project>] " prefix from the terminal tab/window title,
        # leaving just the session name. The prefix is the working directory's
        # basename, not the branch, so on a box where every session runs in the
        # same checkout it repeats one word on every tab — pl-laptop works out
        # of ~/dev/planlab/main, so all of them read "[main] ...". Set
        # [display] title_format instead to build a title out of {project},
        # {group} and {name}; it overrides this toggle. Read once at startup
        # and re-applied to live tmux sessions when the deck picks them up, so
        # restarting agent-deck is enough — sessions need not be recreated.
        include_cwd_prefix = false;
      };

      # Two tool-scoped groups so the quick-create key (N) has a per-tool cursor
      # position: on a group header it takes the tool from that group's most
      # recent session. No default_path — it would have to differ per machine, so
      # the path falls back to the cursor's session, then the launch cwd.
      groups = {
        claude.create = true;
        codex.create = true;
      };

      # agent-deck updates itself by installing a GitHub release over its own
      # binary, which here is a read-only store path owned by the flake. Every one
      # of these either fails or fights `nix flake update`, so turn the whole
      # mechanism off, down to the check that only nags about it.
      updates = {
        auto_update = false; # startup Y/n install prompt
        auto_install = false; # unattended install from the TUI check and the update timer
        auto_restart = false; # re-exec as soon as a newer binary lands on disk
        auto_update_remotes = false; # push this version to remotes running an older one
        check_enabled = false; # the startup and periodic checks themselves
        notify_in_cli = false; # the "update available" line in CLI output
      };
    };

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

    # Everything agent-deck persists that matters is declared above, so link
    # config.toml read-only and let the store path be the whole truth. The
    # trade is that agent-deck's own saves now fail instead of being reverted
    # on the next activation: its atomic save resolves a symlink and writes to
    # the *target* (internal/atomicfile/atomicfile.go:62), so a store path puts
    # the temp file in /nix/store and the write dies with EACCES. The settings
    # panel, the tool-visibility panel and the setup wizard report that in the
    # TUI; the preview-pane width, the new-session dialog's remembered claude
    # flags and the feedback opt-out swallow it and simply stop persisting --
    # declare them here if you want them kept. Sessions and groups created at
    # runtime are unaffected, they live in state.db.
    xdg.configFile."agent-deck/config.toml" = {
      source = configSource;
      # The seeded era left a real file at this path; without force the first
      # switch aborts rather than replacing it. Kept on afterwards so a stray
      # regular file (a save that did land) is healed instead of blocking.
      force = true;
    };
  };
}
