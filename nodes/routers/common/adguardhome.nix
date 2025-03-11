{
  services.adguardhome = {
    enable = true;
    mutableSettings = false;
    host = "[::1]";
    port = 8080;
    settings = {
      dns = {
        bind_hosts = [ "::1" ];
        port = 1053;
        protection_enabled = true;
        cache_size = 0;
        bootstrap_dns = [ ];
        hostsfile_enabled = false;
      };
      filters = [
        {
          enabled = true;
          name = "AdGuard DNS filter";
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
          id = 1;
        }
        {
          enabled = true;
          name = "CHN: anti-AD";
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_21.txt";
          id = 2;
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
      proxyPass = "http://[::1]:8080/";
      recommendedProxySettings = true;
    };
  };

  networking.hostNameAliases = [ "ad" ];
}
