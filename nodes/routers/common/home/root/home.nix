{
  modules',
  osConfig,
  ...
}:
{
  imports = [
    (modules'.fish { promptHostName = true; })
  ];
  programs.helix = {
    enable = true;
    defaultEditor = true;
  };

  home.stateVersion = osConfig.system.stateVersion;
}
