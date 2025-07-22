{
  lib,
  config,
  nodes,
  privatePath,
  ...
}:
{
  sops.secrets.tailscale-authkey = {
    sopsFile = "${privatePath}/nodes/routers/${nodes.current.name}/vpn/tailscale/authkey";
    format = "binary";
  };
  services.tailscale = {
    enable = true;
    interfaceName = "tailscale";
    authKeyFile = config.sops.secrets.tailscale-authkey.path;
    extraUpFlags = [
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
      "--snat-subnet-routes=false"
      "--accept-routes"
      "--advertise-exit-node"
      "--ssh"
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
