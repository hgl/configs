{
  common = {
    os = "nixos";
    channel = "unstable";
  };
  s0 = {
    install = {
      partitions = {
        device = "/dev/sda";
        boot.type = "bios";
        root.format = "xfs";
      };
    };
  };
  s1 = {
    install = {
      partitions = {
        device = "/dev/sda";
        boot.type = "bios";
        root.format = "xfs";
      };
    };
  };
}
