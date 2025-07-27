{
  modules',
  osConfig,
  ...
}:
{
  imports = [
    modules'.fish
  ];

  programs.helix = {
    enable = true;
    defaultEditor = true;
  };

  home.stateVersion = osConfig.system.stateVersion;
}
