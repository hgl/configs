{
  lib,
  pkgs,
  config,
  ...
}:
let
  user = "wordpress-nbhwj";
  dbName = user;
  wordpressDir = "/srv/www/wordpress/nbhwj";
  cacheDir = "/var/cache/backup-nbhwj";
in
{
  systemd.tmpfiles.rules = [
    "d /run/backup-nbhwj - ${user} ${config.users.users.${user}.group}"
    "d ${cacheDir} - ${user} ${config.users.users.${user}.group}"
  ];
  services.openssh.extraConfig = ''
    Match User ${user}
      AcceptEnv NBHWJ_*
      ForceCommand ${
        lib.getExe (
          pkgs.callPackage
            (import ./package {
              inherit wordpressDir cacheDir dbName;
            })
            {
              mariadb = config.services.mysql.package;
            }
        )
      }
  '';
}
