{
  lib,
  pkgs,
  config,
  nodes,
  modules',
  ...
}:

{
  imports = [
    ./nbhwj.nix
    ./glenhuang.nix
    modules'.kiwivm-ga
  ];
  boot.loader.grub = {
    enable = true;
    device = nodes.current.install.partitions.device;
  };
  services.qemuGuest.enable = true;
  services.kiwivm-ga.enable = true;

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
  services.caddy = {
    enable = true;
    virtualHosts = {
      ${config.networking.domain} = {
        useACMEHost = config.networking.domain;
        extraConfig = ''
          header {
            -Server
            Strict-Transport-Security max-age=63072000
          }
          root /srv/www/main
          file_server
          encode gzip zstd
        '';
      };
    };
  };
  systemd.tmpfiles.rules = [
    "d /srv/www/wordpress"
    "d /var/log/phpfpm"
  ];
}
