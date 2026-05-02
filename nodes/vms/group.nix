{
  common =
    { lib, nodes, ... }:
    {
      system = lib.mkDefault "aarch64-linux";
      channel = lib.mkDefault "unstable";
    };
  vm-nixos = {
    deploy.targetHost = "root@192.168.64.3";
    install.targetHost = "root@192.168.64.4";
  };
  vm-nixos-builder = {
    install.targetHost = "root@192.168.3.28";
    deploy.targetHost = "root@vm-nixos-builder.local";
    deploy.buildOnRemote = true;
  };
}
