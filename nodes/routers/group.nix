{
  common =
    {
      common,
      nodes,
      lib',
    }:
    {
      os = "nixos";
      channel = "unstable";
      subrouter = false;
      # Used by the mobileconfig script
      fqdn = nodes.current.config.networking.fqdn;
      dhcp = {
        pool = {
          start = 100;
          end = 250;
        };
      };
      deploy = {
        targetHost = "root@${nodes.current.config.networking.fqdn}";
      };
    };
  r0 =
    { nodes, lib' }:
    {
      index = 0;
      interfaces = lib'.interfaces nodes.current [
        {
          name = "lan";
          ports = [
            "enp1s0"
            "enp2s0"
            "enp3s0"
          ];
        }
        {
          name = "guest-lan";
          vlan = true;
        }
        { name = "y"; }
        { name = "tailscale"; }
        { name = "ipsec"; }
        { name = "wireguard"; }
        { name = "guest-ipsec"; }
      ];
    };
}
