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
    ./nginx.nix
  ];

  boot = {
    initrd.includeDefaultModules = false;
    loader.timeout = 0;

    kernelModules = [ "tcp_bbr" ];
    kernel.sysctl = {
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.core.default_qdisc" = "fq";
    };
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
