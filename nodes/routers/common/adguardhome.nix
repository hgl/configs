{ lib, config, ... }:
{
  services.adguardhome = {
    enable = true;
    mutableSettings = false;
    host = "[::1]";
    port = 5380;
    settings = {
      dns = {
        bind_hosts = [ "::1" ];
        port = 1053;
        cache_enabled = false;
        upstream_dns = config.networking.nameservers;
        bootstrap_dns = [ ];
        hostsfile_enabled = true;
      };
      filters =
        lib.imap0
          (
            i: filter:
            filter
            // {
              enabled = true;
              id = i;
            }
          )
          [
            {
              name = "AdGuard DNS filter";
              url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
            }
            {
              name = "CHN: anti-AD";
              url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_21.txt";
            }
          ];
    };
  };

  services.nginx.virtualHosts.ad = {
    serverName = "ad";
    listen = [
      {
        addr = "[::]";
        port = 80;
      }
      {
        addr = "*";
        port = 80;
      }
    ];
    quic = true;
    locations."/" = {
      proxyPass = "http://${config.services.adguardhome.host}:${toString config.services.adguardhome.port}/";
      recommendedProxySettings = true;
    };
  };

  networkd.hostNameAliases = [ "ad" ];
}
