{ lib, config, ... }:
{
  services.adguardhome = {
    enable = true;
    settings.filters =
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

  router.hostNameAliases = [ "ad" ];
}
