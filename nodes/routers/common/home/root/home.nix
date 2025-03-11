{
  osConfig,
  ...
}:
{
  programs.helix = {
    enable = true;
    defaultEditor = true;
  };

  home.stateVersion = osConfig.system.stateVersion;
}
