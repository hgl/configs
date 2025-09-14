{
  modules',
  osConfig,
  ...
}:
{
  imports = [
    modules'.fish
  ];

  home.stateVersion = osConfig.system.stateVersion;
}
