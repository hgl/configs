{
  lib,
  pkgs,
  config,
  ...
}:

{
  imports = [
    ./nbhwj.nix
  ];
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
    virtualHosts = {
      ${config.networking.domain} = {
        useACMEHost = config.networking.domain;
        extraConfig = ''
          header {
            -Server
            Strict-Transport-Security max-age=63072000
          }
        '';
      };
    };
  };
  systemd.tmpfiles.rules = [
    "d /srv/www/wordpress"
    "d /var/log/phpfpm"
  ];
}
