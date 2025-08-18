{
  lib,
  config,
  nodes,
  ...
}:
{
  sops.secrets.tailscale-authkey = {
    sopsFile = "${nodes.current.privatePath}/vpn/tailscale/authkey";
    format = "binary";
  };
  services.tailscale = {
    enable = true;
    interfaceName = "tailscale";
    authKeyFile = config.sops.secrets.tailscale-authkey.path;
    extraSetFlags = [
      "--advertise-exit-node"
      "--accept-routes"
      "--snat-subnet-routes=false"
      "--ssh"
      "--accept-dns=false"
      "--advertise-routes=${
        lib.concatStringsSep "," (
          lib.concatMap
            (interfaceName: [
              (config.router.interfaces.${interfaceName}.ipv6 {
                interfaceId = 0;
                prefixLength = 64;
              })
              (config.router.interfaces.${interfaceName}.ipv4 {
                hostId = 0;
                prefixLength = 24;
              })
            ])
            [
              config.router.interfaces.lan.name
              config.router.interfaces.guest-lan.name
              config.router.interfaces.ipsec.name
              config.router.interfaces.guest-ipsec.name
            ]
        )
      }"
    ];
  };

  services.dnsmasq.settings = {
    # insecure, but is required for local resolver to work
    # for site-to-site tailscale
    stop-dns-rebind = false;
    # TODO: find out why using IPv6 here resulting in hanging DNS queries
    server =
      lib.mapAttrsToList (_: router: "//${router.config.router.interfaces.lan.ipv4 { hostId = 1; }}") (
        lib.removeAttrs nodes.routers.nodes [ nodes.current.name ]
      )
      ++ [ "/ts.net/100.100.100.100" ];
  };

  router.interfaces.wan.nftables.chains.filter.input.filter = ''
    udp dport ${toString config.services.tailscale.port} accept comment "Allow tailscale"
  '';

  # For site-to-site tunnel
  # https://tailscale.com/kb/1214/site-to-site#clamp-the-mss-to-the-mtu
  networking.nftables.tables."interface-${config.services.tailscale.interfaceName}" = {
    family = "inet";
    content = ''
      chain forward {
        type filter hook forward priority mangle;
        oifname "${config.services.tailscale.interfaceName}" tcp flags syn tcp option maxseg size set rt mtu
      }
    '';
  };
}
