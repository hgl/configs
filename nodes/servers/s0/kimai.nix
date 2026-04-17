{ config, ... }:
{
  services.kimai.sites.kimai = {
    database.socket = "/run/mysqld/mysqld.sock";
  };

  services.nginx.virtualHosts.kimai = {
    serverName = "kimai.${config.networking.domain}";
    forceSSL = true;
    enableACME = true;
  };
}
