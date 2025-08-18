{
  pkgs,
  modulesPath,
  inputs',
  config,
  ...
}:
{
  imports = [
    "${modulesPath}/profiles/minimal.nix"
    inputs'.nix-networkd.modules.nix-networkd
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

  security.acme = {
    acceptTerms = true;
    defaults = {
      webroot = "/var/lib/acme/acme-challenge";
    };
  };

  services.caddy = {
    enable = true;
    globalConfig = ''
      auto_https off
    '';
    virtualHosts = {
      acme = {
        hostName = "http://";
        logFormat = ''
          output file ${config.services.caddy.logDir}/access-http.log
        '';
        extraConfig = ''
          header -Server
          handle /.well-known/acme-challenge/* {
            file_server {
              root ${config.security.acme.defaults.webroot}
            }
          }
          handle {
            redir https://{host}{uri} 301
          }
        '';
      };
      ${config.networking.fqdn} = {
        useACMEHost = config.networking.fqdn;
        serverAliases = [ "https://" ];
        logFormat = ''
          output file ${config.services.caddy.logDir}/access-${config.networking.fqdn}.log
        '';
        extraConfig = ''
          header {
            -Server
            Strict-Transport-Security max-age=63072000
          }
          root /srv/www/host
          file_server
          encode gzip zstd
        '';
      };
    };
  };

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
