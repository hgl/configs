{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./nginx.nix
    ./nbhwj.nix
    ./backup-nbhwj
    ./matrix.nix
  ];
  boot.loader.grub.enable = true;

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

  systemd.tmpfiles.rules = [
    "d /srv/www/wordpress"
    "d /var/log/phpfpm"
  ];
}
