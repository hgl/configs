{ config, ... }:
{
  home.sessionVariables = {
    PYTHONPYCACHEPREFIX = "${config.xdg.cacheHome}/pycache";
  };
}
