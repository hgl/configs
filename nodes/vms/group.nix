{
  common =
    { lib, nodes, ... }:
    {
      system = lib.mkDefault "aarch64-linux";
      channel = lib.mkDefault "unstable";
      deploy = {
        targetHost = lib.mkDefault "root@${nodes.current.name}.local";
      };
    };
  vm-nixos =
    { lib, nodes, ... }:
    {
      install.targetHost = "root@192.168.64.21";
    };
  vm-nixos-builder = {
    install.targetHost = "root@192.168.3.28";
    deploy.buildOnRemote = true;
  };
}
