{
  common =
    { lib, nodes, ... }:
    {
      os = lib.mkDefault "nixos";
      channel = lib.mkDefault "unstable";
      deploy.targetHost = lib.mkDefault "root@${nodes.current.name}.local";
    };
  vm-nixos = {
    install = {
      targetHost = "root@192.168.64.11";
    };
    deploy.buildOnRemote = true;
  };
}
