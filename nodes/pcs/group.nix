{
  hgl = {
    os = "darwin";
    channel = "master";
  };
  hgl2 = {
    os = "nixos";
    channel = "unstable";
    install = {
      targetHost = "root@nixos";
      partitions = {
        device = "/dev/nvme0n1";
        boot.type = "efi";
        root.format = "ext4";
      };
    };
    deploy = {
      targetHost = "root@hgl2";
    };
  };
}
