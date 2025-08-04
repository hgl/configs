{
  lib,
  pkgs,
  inputs',
  modulesPath,
  ...
}:
{
  imports = [
    "${modulesPath}/profiles/minimal.nix"
    inputs'.nixos-router.modules.nixos-router
    ./adguardhome.nix
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

  router = {
    enable = true;
    interfaces = {
      lan = {
        type = "bridge";
        subnetId = 0;
      };
      guest-lan = {
        type = "vlan";
        subnetId = 1;
        vlanId = 2;
        quarantine = {
          enable = true;
        };
      };
      ipsec = {
        type = "xfrm";
        subnetId = 2;
        xfrmId = 1;
      };
      guest-ipsec = {
        type = "xfrm";
        subnetId = 3;
        xfrmId = 2;
        quarantine = {
          enable = true;
        };
      };
      wan = {
        type = "wan";
        nftables.inputChain = ''
          tcp dport 22 accept comment "Allow SSH"
        '';
      };
    };
  };
  security.acme.acceptTerms = true;

  environment.systemPackages = with pkgs; [
    ghostty.terminfo
    dig
    tcpdump
    openssl
    btop
    mtr
    smartmontools
    dmidecode
  ];

  system.stateVersion = "24.05";
}
