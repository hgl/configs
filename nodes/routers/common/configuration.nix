{
  lib,
  pkgs,
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

  nixpkgs.overlays = [
    (final: prev: {
      # Address a bug in nftable 1.1.6
      # https://marc.info/?l=netfilter&m=177258727013124&w=2
      nftables =
        let
          inherit (pkgs) fetchurl;
        in
        prev.nftables.overrideAttrs (oldAttrs: {
          patches = oldAttrs.patches ++ [
            (fetchurl {
              name = "0005-mnl-fix.patch";
              url = "https://git.netfilter.org/nftables/patch/?id=e83e32c8d1cd228d751fb92b756306c6eb6c0759";
              hash = "sha256-OoDWsx9kkbVMXCoM2QcCfntn5xpitbqunLxl8dez98k=";
            })
          ];
        });
    })
  ];

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

  security.acme.acceptTerms = true;

  environment.systemPackages = with pkgs; [
    ghostty.terminfo
  ];

  system.stateVersion = "24.05";
}
