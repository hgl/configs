{
  boot.loader.grub.device = "/dev/sda";
  swapDevices = [
    {
      device = "/swapfile";
      size = 1024;
    }
  ];
}
