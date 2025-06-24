{
  lib,
  config,
  ...
}:
{
  options = {
    networking.hostNameAliases = lib.mkOption {
      type = lib.types.listOf lib.types.nonEmptyStr;
      default = [ ];
    };
  };
  config = {
    networking.resolvconf.extraConfig = ''
      name_servers='223.5.5.5 2400:3200::1'
    '';
    services.dnsmasq = {
      enable = true;
      resolveLocalQueries = false;
      settings = {
        interface = [
          "lan"
          "guest-lan"
          "ipsec"
          "guest-ipsec"
        ];
        no-dhcp-interface = [
          "ipsec"
          "guest-ipsec"
        ];
        bind-interfaces = true;
        dhcp-authoritative = true;
        domain-needed = true;
        no-resolv = true;
        localise-queries = true;
        expand-hosts = true;
        bogus-priv = true;
        enable-dbus = true;
        # dhcp-fqdn = true;
        stop-dns-rebind = true;
        rebind-localhost-ok = true;
        dns-forward-max = 1000;
        enable-ra = true;
        server = [
          "::1#1053"
        ];
        # domain = node'.searchDomain;
        dhcp-option = [
          "option:dns-server,0.0.0.0"
          # "option:domain-search,${node'.searchDomain}"
          "option6:dns-server,[fd00::]"
          # "option6:domain-search,${node'.searchDomain}"
        ];
        interface-name = lib.mapCartesianProduct ({ domain, interface }: "${domain},${interface}") {
          domain = [
            config.networking.hostName
            config.networking.fqdn
          ] ++ config.networking.hostNameAliases;
          interface = [
            "lan"
            "ipsec"
          ];
        };
      };
    };
  };
}
