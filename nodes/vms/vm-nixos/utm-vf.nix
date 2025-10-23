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
    "L /home/hgl/dev - - - - /mnt/share/dev"
  ];
}
