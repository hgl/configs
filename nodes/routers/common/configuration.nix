{
  lib,
  pkgs,
  modulesPath,
  modules',
  nodes,
  ...
}:
{
  imports = [
    "${modulesPath}/profiles/minimal.nix"
    modules'.ipmon
    ./lan.nix
    ./wan.nix
    ./dnsmasq.nix
    ./adguardhome.nix
    ./ipsec.nix
    ./nginx.nix
    ./ddns.nix
    ./tailscale.nix
  ];

  boot = {
    initrd = {
      includeDefaultModules = false;
      # Without this booting shows "Failure to communicate with kernel device-mapper driver."
      kernelModules = [ "dm_mod" ];
    };
    loader = {
      timeout = 0;
      systemd-boot.enable = true;
    };
    # kernelModules = [ "tcp_bbr" ];
    kernel.sysctl = {
      "net.ipv4.conf.all.forwarding" = true;
      "net.ipv6.conf.all.forwarding" = true;
      # "net.ipv4.tcp_congestion_control" = "bbr";
      # "net.core.default_qdisc" = "fq";
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

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
    # installed with nixos-anywhere's --extra-files
    hostKeys = [ ];
  };

  users.mutableUsers = false;
  users.users.root = {
    shell = pkgs.fish;
  };
  programs.fish = {
    enable = true;
    promptInit = ''
      function fish_prompt
        printf '%s❯ ' (prompt_hostname)
      end
      function fish_right_prompt
        echo -n -s (prompt_pwd --full-length-dirs 2) (fish_vcs_prompt) ' ' (date +%H:%M:%S)
      end
    '';
    shellInit = ''
      set -U fish_greeting
    '';
  };

  networking = {
    hostName = if nodes.current.subrouter then "${nodes.current.name}sub" else nodes.current.name;
    useDHCP = false;
    firewall.enable = false;
    # search = [ node'.searchDomain ];
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

  systemd.network.enable = true;

  # Enabled by networkd by default, we use dnsmasq for dns, so turn it off here
  services.resolved.enable = false;

  networking.nftables.enable = true;

  security.acme = {
    acceptTerms = true;
  };

  environment.systemPackages = with pkgs; [
    ghostty.terminfo
    dig
    tcpdump
    openssl
    btop
    mtr
  ];

  system.stateVersion = "24.05";
}
