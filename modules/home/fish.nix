{
  programs.fish = {
    enable = true;
    functions = {
      fish_prompt = ''
        printf '%s' (prompt_hostname)
        if test -n "$ZMX_SESSION"
          printf '[%s]' "$ZMX_SESSION"
        end
        printf '❯ '
      '';
      fish_right_prompt = ''
        echo -n -s (prompt_pwd --full-length-dirs 2) (fish_vcs_prompt) ' ' (date +%H:%M:%S)
      '';
    };
    interactiveShellInit = ''
      set -U fish_greeting
    '';
  };
}
