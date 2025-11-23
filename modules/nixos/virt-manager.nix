{ user }:
{ pkgs, ... }:
{
  users.users.${user}.extraGroups = [ "libvirtd" ];
  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.qemu.vhostUserPackages = [ pkgs.virtiofsd ];
  programs.virt-manager.enable = true;
}
