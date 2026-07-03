{ modules', pkgs', ... }: {
  imports = [
    modules'.rift
  ];

  services.rift = {
    enable = true;
    package = pkgs'.rift;
  };
}
