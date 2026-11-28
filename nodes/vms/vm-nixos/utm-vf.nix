{ config, nodes, ... }:
let
  home = config.users.users.${nodes.current.users.main.name}.home;
in
{
  services.spice-vdagentd.enable = true;
  virtualisation.rosetta.enable = true;

  fileSystems."/mnt/share" = {
    fsType = "virtiofs";
    device = "share";
    options = [
      "rw"
      "nofail"
    ];
  };

  systemd.tmpfiles.rules = [
    "L ${home}/dev - - - - /mnt/share/dev"
    "L ${home}/lab - - - - /mnt/share/lab"
  ];
}
