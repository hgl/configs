{
  config,
  lib,
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
    extraUpFlags =
      let
        routes =
          lib.concatMap
            (interface: [
              (nodes.current.interfaces.${interface}.ipv4 {
                suffix = 0;
                cidr = true;
              })
              (nodes.current.interfaces.${interface}.ipv6 {
                suffix = 0;
                cidr = true;
              })
            ])
            [
              "lan"
              "guest-lan"
              "ipsec"
            ];
      in
      [
        "--advertise-routes=${lib.concatStringsSep "," routes}"
        "--snat-subnet-routes=false"
        "--accept-routes"
        "--advertise-exit-node"
        "--ssh"
      ];
  };
  networking.wan.allowedTraffics = [
    {
      protocols = [ "udp" ];
      destination.ports = [ config.services.tailscale.port ];
    }
  ];
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
