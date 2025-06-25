{
  common =
    { nodes }:
    {
      os = "nixos";
      channel = "unstable";
      deploy = {
        targetHost = "root@${nodes.current.config.networking.fqdn}";
      };
    };
  s0 = {
    install = {
      partitions = {
        device = "/dev/sda";
        boot.type = "bios";
        root.format = "xfs";
        swap.enable = true;
      };
    };
  };
  s1 = {
    install = {
      partitions = {
        device = "/dev/vda";
        boot.type = "efi";
        root.format = "xfs";
        swap.enable = true;
      };
    };
  };
}
