{ promptHostName }:
{
  programs.fish = {
    enable = true;
    functions = {
      fish_prompt = ''
        ${if promptHostName then "printf '%s❯ ' (prompt_hostname)" else "printf '❯ '"}
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
