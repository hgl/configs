{
  lib,
  lib',
  config,
  ...
}:
let
  dnsInterfaces = lib.filterAttrs (
    _: interface: interface.dns.enable or false
  ) config.router.interfaces;
  adguardhome =
    let
      inherit (config.services.adguardhome.settings.dns) bind_hosts port;
    in
    "${lib.head bind_hosts}#${toString port}";
in
{
  services.dnsmasq = {
    enable = true;
    settings = {
      bind-interfaces = true;
      dhcp-authoritative = true;
      no-resolv = true;
      resolv-file = false;
      localise-queries = true;
      expand-hosts = true;
      bogus-priv = true;
      enable-dbus = true;
      dns-forward-max = 1000;
      enable-ra = true;
      server = [ adguardhome ];
      interface = lib.attrNames dnsInterfaces;
      no-dhcp-interface = lib'.concatMapAttrsToList (
        _: interface: lib.optional (!(interface.dhcpServer.enable or false)) interface.name
      ) dnsInterfaces;
      dhcp-range = lib'.concatMapAttrsToList (
        _: interface:
        lib.optionals (interface.dhcpServer.enable or false) [
          "::,constructor:${interface.name},slaac,7d"
          (lib.concatStringsSep "," [
            interface.dhcpServer.poolv4.startIp
            interface.dhcpServer.poolv4.endIp
          ])
        ]
      ) dnsInterfaces;
      interface-name = lib'.concatMapAttrsToList (
        _: interface:
        lib.optionals (!(interface.quarantine.enable or false)) (
          map (domain: "${domain},${interface.name}") (
            [
              config.networking.hostName
              config.networking.fqdn
            ]
            ++ config.router.hostNameAliases
          )
        )
      ) dnsInterfaces;
      dhcp-host = lib'.concatMapAttrsToList (
        _: interface:
        lib'.concatMapAttrsToList (
          _: lease:
          lib.optional lease.enable "${lease.hostName},${lease.macAddress},${
            interface.ipv4 { inherit (lease) hostId; }
          }"
        ) interface.dhcpServer.staticLeases or { }
      ) dnsInterfaces;
    };
  };
}
