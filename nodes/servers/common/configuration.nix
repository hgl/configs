{
  pkgs,
  modulesPath,
  inputs',
  ...
}:
{
  imports = [
    "${modulesPath}/profiles/minimal.nix"
    inputs'.nix-networkd.modules.nix-networkd
    ./bbr.nix
    ./nginx.nix
  ];

  boot = {
    initrd.includeDefaultModules = false;
    loader.timeout = 0;
  };

  nix = {
    optimise.automatic = true;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  time.timeZone = "Asia/Shanghai";

  users.mutableUsers = false;
  users.users.root = {
    shell = pkgs.fish;
  };
  programs.fish = {
    enable = true;
  };
  environment.shells = with pkgs; [
    fish
  ];

  environment.systemPackages = with pkgs; [
    ghostty.terminfo
    dig
    tcpdump
    btop
    iperf
    rsync
    traceroute
    mtr
  ];

  system.stateVersion = "24.05";
}
