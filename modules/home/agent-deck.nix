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
  codexLauncher = pkgs.writeShellScript "agent-deck-codex" ''
    # Codex queries the terminal palette once at startup. A detached tmux
    # session has no terminal to answer, so wait for the first attachment.
    # Once started, Codex can keep running normally after the client detaches.
    if [[ -n "''${TMUX:-}" && -n "''${TMUX_PANE:-}" && -t 1 ]]; then
      session=$(${lib.getExe pkgs.tmux} display-message -p -t "$TMUX_PANE" '#{session_id}')
      attached() {
        # agent-deck's control-mode clients do not supply a terminal palette.
        [[ "$(${lib.getExe pkgs.tmux} list-clients -t "$session" -F '#{client_control_mode}')" == *0* ]]
      }
      while ! attached; do
        sleep 0.05
      done
      # Attachment is not a palette-ready signal. Probe tmux until it can
      # answer both colors, including when a client was already attached.
      # Bound the wait for terminals that do not implement OSC 10/11.
      ${lib.getExe pkgs.python3} ${./agent-deck-wait-palette.py} ${lib.getExe pkgs.tmux} || true
    fi
    exec ${lib.getExe config.programs.codex.package} ${lib.escapeShellArgs cfg.codexArgs} "$@"
  '';
  claudeLauncher = pkgs.writeShellScript "agent-deck-claude" ''
    # Put the outer terminal's identity back for Claude. Claude only emits the
    # OSC 9;4 progress sequence -- what makes Ghostty draw the bar sliding back
    # and forth across the top of the window while a turn runs -- for terminals
    # it recognises from TERM_PROGRAM/TERM_PROGRAM_VERSION: ghostty >= 1.2.0,
    # iTerm2 >= 3.6.6 or ConEmu. tmux overwrites both in every pane with its
    # own name and version, so in a deck session Claude reads "tmux"/"3.7c" and
    # stays silent. It special-cases TERM_PROGRAM=tmux for hyperlinks but not
    # for progress, hence the restore here rather than a flag. Same blind spot
    # as the SSH one these vars are in SendEnv/AcceptEnv for, different carrier.
    #
    # The session environment has the real values once a client has attached
    # (update-environment, set in tmux.conf below) and tracks re-attaches; the
    # server's global environment holds whatever started it, which covers the
    # gap before the first attach, since agent-deck starts a session detached
    # and only then attaches to it.
    if [[ -n "''${TMUX:-}" ]]; then
      outer() {
        local line scope
        for scope in "" -g; do
          line=$(${lib.getExe pkgs.tmux} show-environment $scope "$1" 2>/dev/null) || continue
          # show-environment answers "-NAME" for a variable it knows is unset.
          [[ $line == "$1="* ]] || continue
          printf '%s' "''${line#*=}"
          return 0
        done
        return 1
      }
      program=$(outer TERM_PROGRAM) || true
      # A nested deck would report tmux again; leave the pane's value alone then.
      if [[ -n "$program" && "$program" != tmux ]]; then
        export TERM_PROGRAM="$program"
        version=$(outer TERM_PROGRAM_VERSION) || true
        [[ -n "$version" ]] && export TERM_PROGRAM_VERSION="$version"
      fi
    fi
    exec ${lib.getExe config.programs.claude-code.package} "$@"
  '';
in
{
  options.programs.agent-deck.codexArgs = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    description = "Arguments passed to every Codex invocation launched by Agent Deck.";
  };

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
      theme = "dark";
      codex.command = toString codexLauncher;
      claude.command = toString claudeLauncher;

      tmux = {
        # Host sessions on their own tmux server (tmux -L agent-deck) so agent-deck's
        # bind-key, set-option and status line mutations stay off the default server.
        # Each session records this at creation time and is never migrated, so it has
        # to be set before the first session exists.
        socket_name = "agent-deck";

        # Preserve the terminal background even when the OS uses a light theme.
        window_style_override = "default";
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

    # tmux reads this at server startup whatever socket it is on, so it reaches
    # the deck's own server (tmux -L agent-deck) too. Nothing else here uses
    # tmux -- zmx is a separate multiplexer -- so the file is all agent-deck's.
    # A rebuild does not reach a server that is already up: the settings land
    # when it next starts, i.e. once every deck session is gone.
    xdg.configFile."tmux/tmux.conf".text = ''
      # tmux parses OSC 9;4 out of the pane either way -- #{pane_pb_state} goes
      # to "indeterminate" -- but only re-emits it to a client whose terminal is
      # flagged able to take it, and swallows it otherwise. Its built-in table
      # grants "progressbar" to mintty and iTerm2 alone, and xterm-ghostty's
      # terminfo carries no Spb capability for tmux to pick it up from, so
      # Ghostty has to be named here or Claude's progress bar dies at the tmux
      # boundary. Resolved per client at attach time, so an attached client only
      # picks this up on re-attach.
      set -as terminal-features ",xterm-ghostty:progressbar"

      # Keep the outer terminal reachable from inside a pane, where tmux has
      # replaced TERM_PROGRAM/TERM_PROGRAM_VERSION with its own name and
      # version. The claude launcher reads these back out of the session
      # environment; update-environment refreshes them on every attach, so a
      # session that gets picked up from a different terminal reports that one.
      set -ga update-environment TERM_PROGRAM
      set -ga update-environment TERM_PROGRAM_VERSION
    '';

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

    # Agent Deck execs Codex directly, bypassing the interactive shell alias.
    # Apply these defaults on every host, including local and remote sessions.
    programs.agent-deck.codexArgs = [ "--no-daemon" ];
    programs.agent-deck.settings.codex.yolo_mode = true;
  };
}
