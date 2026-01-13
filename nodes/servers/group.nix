{
  common =
    { lib, nodes, ... }:
    {
      os = "nixos";
      channel = "unstable";
      deploy = {
        useSubstitutes = lib.mkDefault false;
        targetHost = lib.mkDefault "root@${nodes.current.config.networking.fqdn}";
      };
    };
  s0 = { };
  s1 = { };
}
