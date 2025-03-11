{
  modules',
  osConfig,
  ...
}:
{
  imports = [
    (modules'.fish { promptHostName = true; })
  ];

  home.stateVersion = osConfig.system.stateVersion;
}
