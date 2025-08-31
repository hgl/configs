{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./nbhwj.nix
    ./backup-nbhwj
  ];
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };
  fileSystems."/" = {
    device = "/dev/disk/by-partlabel/root";
    fsType = "xfs";
  };
  swapDevices = [
    {
      device = "/dev/disk/by-partlabel/swap";
    }
  ];

  systemd.network = {
    networks."99-default" = {
      matchConfig = {
        Name = "*";
      };
      networkConfig = {
        DHCP = true;
      };
    };
  };

  services.mysql = {
    package = pkgs.mariadb_114;
    settings = {
      server = {
        skip-networking = true;
      };
      client-server = {
        socket = "/run/mysqld/mysqld.sock";
      };
    };
  };
  services.phpfpm = {
    settings = {
      error_log = lib.mkForce "/var/log/phpfpm/error.log";
    };
  };
  services.nginx.virtualHosts.${config.networking.domain} = {
    quic = true;
    forceSSL = true;
    enableACME = true;
    extraConfig = ''
      add_header Strict-Transport-Security "max-age=63072000" always;
      add_header Alt-Svc 'h3=":$server_port"; ma=2592000';
    '';
  };
  systemd.tmpfiles.rules = [
    "d /srv/www/wordpress"
    "d /var/log/phpfpm"
  ];
}
