{
  common =
    { lib, nodes, ... }:
    {
      system = lib.mkDefault "x86_64-linux";
      channel = lib.mkDefault "unstable";
      deploy = {
        useSubstitutes = lib.mkDefault false;
        targetHost = lib.mkDefault "root@${nodes.current.config.networking.fqdn}";
      };
    };
  r0 = { };
  r1 = { };
}
