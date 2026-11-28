{ pkgs, nodes, ... }:
{
  users.users.${nodes.current.users.main.name}.extraGroups = [ "libvirtd" ];
  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.qemu.vhostUserPackages = [ pkgs.virtiofsd ];
  programs.virt-manager.enable = true;
}
