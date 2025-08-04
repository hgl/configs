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
      "--accept-dns=false" # this prevents tailscale from overwriting /etc/resolv.conf
      "--advertise-exit-node"
      "--accept-routes"
      "--snat-subnet-routes=false"
      "--ssh"
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
              "lan"
              "ipsec"
            ]
        )
      }"
    ];
  };

  router.interfaces.wan.nftables.inputChain = ''
    udp dport ${toString config.services.tailscale.port} accept comment "Allow tailscale"
  '';

  # For site-to-site tunnel
  networking.nftables.tables.tailscale = {
    family = "inet";
    content = ''
      chain forward {
        type filter hook forward priority filter;
        oifname "${config.services.tailscale.interfaceName}" tcp flags syn tcp option maxseg size set rt mtu
      }
    '';
  };
}
