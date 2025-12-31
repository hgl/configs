{
  lib,
  lib',
  config,
  ...
}:
{
  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
    "2606:4700:4700::1111"
    "2606:4700:4700::1001"
  ];

  services.doh-server = {
    enable = true;
    settings = {
      listen = [
        "[::1]:8053"
      ];
      upstream = map (
        address:
        "udp:${
          lib'.addressPortString {
            inherit address;
            port = 53;
          }
        }"
      ) config.networking.nameservers;
    };
  };

  services.nginx = {
    virtualHosts.host.locations."/dns-query" = {
      proxyPass = "http://${lib.elemAt config.services.doh-server.settings.listen 0}/dns-query";
      recommendedProxySettings = true;
    };
  };
}
