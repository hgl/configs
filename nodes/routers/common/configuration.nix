{
  lib,
  pkgs,
  config,
  modulesPath,
  ...
}:
{
  imports = [
    "${modulesPath}/profiles/minimal.nix"
    ./dns.nix
    ./adguardhome.nix
    ./networkd.nix
    ./ipsec.nix
    ./nginx.nix
    ./ddns.nix
    ./tailscale.nix
  ];

  boot = {
    initrd = {
      includeDefaultModules = false;
    };
    loader = {
      timeout = 2;
      systemd-boot.enable = true;
    };
    kernelModules = [ "tcp_bbr" ];
    kernel.sysctl = {
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.core.default_qdisc" = "fq";
    };
  };

  nixpkgs.config.allowUnfree = true;
  nix = {
    settings = {
      auto-optimise-store = true;
      substituters = lib.mkForce [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" ];
    };
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
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

  networking = {
    nameservers = [ "223.5.5.5" ];
    timeServers = [
      "ntp.aliyun.com"
      "ntp1.aliyun.com"
      "ntp2.aliyun.com"
      "ntp3.aliyun.com"
      "ntp4.aliyun.com"
      "ntp5.aliyun.com"
      "ntp6.aliyun.com"
      "ntp7.aliyun.com"
    ];
  };

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv6.conf.all.forwarding" = true;
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      # dnsmasq negatively caches the _acme-challenge lookup for the zone's SOA
      # minimum (30m on Cloudflare), so lego's recursive propagation check keeps
      # seeing NXDOMAIN for the record it just created. Only wait for the
      # authoritative nameservers, and bypass dnsmasq for the remaining lookups.
      dnsResolver = "${lib.head config.networking.nameservers}:53";
      extraLegoFlags = [ "--dns.propagation.disable-rns" ];
    };
  };

  environment.systemPackages = with pkgs; [
    ghostty.terminfo
  ];

  system.stateVersion = "24.05";
}
