{ pkgs, pkgs', ... }: {
  home.packages = with pkgs; [
    pkgs'.zmx
    fzf
  ];

  # Port of the session picker recipe from https://zmx.sh/#session-picker
  programs.fish.functions.zmx = ''
    if test "$argv[1]" = pick
      set -l display
      for line in (command zmx list 2>/dev/null)
        set -l name
        set -l pid
        set -l clients
        set -l dir
        for field in (string split \t -- $line)
          set -l kv (string split -m1 = -- $field)
          switch $kv[1]
            # the name key carries an arrow/space prefix inside a session
            case '*name'
              set name $kv[2]
            case pid
              set pid $kv[2]
            case clients
              set clients $kv[2]
            case start_dir
              set dir $kv[2]
          end
        end
        test -n "$name"; or continue
        set -a display (printf '%-20s  pid:%-8s  clients:%-2s  %s' "$name" "$pid" "$clients" "$dir")
      end

      set -l output (string join \n -- $display | fzf \
        --print-query \
        --expect=ctrl-n \
        --height=80% \
        --reverse \
        --prompt='zmx> ' \
        --header='Enter: select | Ctrl-N: create new' \
        --preview='zmx history {1}' \
        --preview-window=right:60%:follow)
      set -l rc $status
      set -l query $output[1]
      set -l key $output[2]
      set -l selected $output[3]

      set -l session_name
      if test "$key" = ctrl-n; and test -n "$query"
        set session_name $query
      else if test $rc -eq 0; and test -n "$selected"
        set session_name (string match -r '^\S+' -- $selected)
      else if test -n "$query"
        set session_name $query
      else
        return 130
      end
      command zmx attach $session_name
    else
      command zmx $argv
    end
  '';
}
