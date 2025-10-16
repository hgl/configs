{
  common =
    { lib, nodes, ... }:
    {
      os = lib.mkDefault "nixos";
      channel = lib.mkDefault "unstable";
    };
  vm-nixos = {
    install.targetHost = "root@192.168.7.2";
    deploy.targetHost = "root@192.168.7.2";
  };
  vm-nixos-builder = {
    install.targetHost = "root@192.168.3.28";
    deploy.targetHost = "root@vm-nixos-builder.local";
    deploy.buildOnRemote = true;
  };
}
