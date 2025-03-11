{ nodes }:
{
  os = "nixos";
  channel = "unstable";
  install = {
    targetHost = "root@192.168.64.4";
    partitions = {
      device = "/dev/vda";
      boot.type = "efi";
      root.format = "ext4";
    };
  };
  deploy = {
    targetHost = "root@${nodes.current.name}.local";
    buildHost = "root@${nodes.current.name}.local";
  };
}
