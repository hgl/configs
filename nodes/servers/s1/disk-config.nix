{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/sda";
    content = {
      type = "gpt";
      partitions = {
        boot = {
          label = "boot";
          size = "1M";
          type = "EF02";
        };
        swap = {
          label = "swap";
          end = "2G";
          content.type = "swap";
        };
        root = {
          label = "root";
          size = "100%";
          content = {
            type = "filesystem";
            format = "xfs";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
