{
  common =
    { lib, nodes, ... }:
    {
      os = "nixos";
      channel = "unstable";
      deploy = {
        targetHost = lib.mkDefault "root@${nodes.current.config.networking.fqdn}";
      };
    };
}
