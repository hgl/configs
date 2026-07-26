{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    python3
  ];

  home.sessionVariables = {
    PYTHONPYCACHEPREFIX = "${config.xdg.cacheHome}/pycache";
  };
}
