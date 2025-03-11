{
  hgl = {
    os = "darwin";
    channel = "unstable";
    deploy = {
      local = true;
    };
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
      buildHost = "root@hgl2";
    };
  };
}
