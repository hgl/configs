{
  common =
    { nodes, ... }:
    {
      os = "nixos";
      channel = "unstable";
      deploy = {
        targetHost = "root@${nodes.current.config.networking.fqdn}";
      };
    };
  s0 = { };
  s1 = { };
}
