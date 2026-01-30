{
  modules',
  pkgs,
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

  home.packages = with pkgs; [
    dig
    tcpdump
    openssl
    btop
    mtr
    smartmontools
    dmidecode
    iperf
    speedtest-cli
  ];

  home.stateVersion = osConfig.system.stateVersion;
}
