{ pkgs, ... }:
{
  system.fsPackages = [ pkgs.open-vm-tools ];
  virtualisation.vmware.guest.enable = true;

  fileSystems."/home/hgl/dev" = {
    device = ".host:/dev";
    fsType = "fuse./run/current-system/sw/bin/vmhgfs-fuse";
    options = [
      "umask=22"
      "uid=1000"
      "gid=100"
      "allow_other"
      "defaults"
      "auto_unmount"
    ];
  };
}
