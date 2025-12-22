{
  lib,
  pkgs,
  nodes,
  config,
  ...
}:
let
  inherit (lib) types;
  mainDomain = lib.head config.services.wordpress-nbhwj.domains;
in
{
  options.services.wordpress-nbhwj = {
    user = lib.mkOption {
      type = types.nonEmptyStr;
      default = "wordpress-nbhwj";
    };
    db = lib.mkOption {
      type = types.nonEmptyStr;
      default = config.services.wordpress-nbhwj.user;
    };
    domains = lib.mkOption {
      type = types.nonEmptyListOf types.nonEmptyStr;
      default = [
        "nbhwj.com"
        "www.nbhwj.com"
      ];
    };
    sockets = {
      nginx = lib.mkOption {
        type = types.nonEmptyStr;
        default = "/run/nginx/wordpress-nbhwj.sock";
      };
      phpfpm = lib.mkOption {
        type = types.nonEmptyStr;
        readOnly = true;
        default = config.services.phpfpm.pools.wordpress-nbhwj.socket;
      };
    };
    dir = lib.mkOption {
      type = types.nonEmptyStr;
      default = "/srv/www/wordpress/nbhwj";
    };
  };
  config = {
    services.mysql = {
      enable = true;
      ensureDatabases = [ config.services.wordpress-nbhwj.db ];
      ensureUsers = [
        {
          name = config.services.wordpress-nbhwj.user;
          ensurePermissions = {
            "\\`${config.services.wordpress-nbhwj.db}\\`.*" = "ALL PRIVILEGES";
          };
        }
      ];
    };
    users.users.${config.services.wordpress-nbhwj.user} = {
      group = config.services.nginx.group;
      extraGroups = [ "systemd-journal" ];
      isSystemUser = true;
      shell = pkgs.bash;
      openssh.authorizedKeys.keyFiles = [
        "${nodes.r0.privatePath}/fs/root/.ssh/id_nbhwj.pub"
      ];
    };
    services.phpfpm.pools.wordpress-nbhwj = {
      inherit (config.services.wordpress-nbhwj) user;
      group = config.services.nginx.group;
      phpPackage = pkgs.php84.withExtensions (
        { enabled, all }:
        enabled
        ++ (with all; [
          imagick
          apcu
        ])
      );
      settings = {
        "listen.owner" = config.services.nginx.user;
        "listen.group" = config.services.nginx.group;
        "pm" = "dynamic";
        "pm.max_children" = 32;
        "pm.start_servers" = 2;
        "pm.min_spare_servers" = 2;
        "pm.max_spare_servers" = 4;
        "pm.max_requests" = 500;
        "catch_workers_output" = true;
      };
    };
    systemd.tmpfiles.rules = [
      "d ${config.services.wordpress-nbhwj.dir} - ${config.services.wordpress-nbhwj.user} ${
        config.users.users.${config.services.wordpress-nbhwj.user}.group
      }"
    ];
    services.nginx = {
      preread.upstreams = lib.genAttrs config.services.wordpress-nbhwj.domains (
        domain: "unix:${config.services.wordpress-nbhwj.sockets.nginx}"
      );
      virtualHosts.wordpress-nbhwj = {
        serverName = mainDomain;
        serverAliases = lib.drop 1 config.services.wordpress-nbhwj.domains;
        listen = [
          {
            addr = "unix:${config.services.wordpress-nbhwj.sockets.nginx}";
            ssl = true;
          }
        ];
        onlySSL = true;
        enableACME = true;
        root = config.services.wordpress-nbhwj.dir;
        locations = {
          "= /favicon.ico" = {
            extraConfig = ''
              log_not_found off;
              access_log off;
            '';
          };
          "= robots.txt" = {
            extraConfig = ''
              log_not_found off;
              access_log off;
            '';
          };
          "/" = {
            index = "index.php";
            tryFiles = "$uri $uri/ /index.php?$args";
          };
          # Deny access to any files with a .php extension in the uploads directory
          # Works in sub-directory installs and also in multisite network
          # Keep logging the requests to parse later (or to pass to firewall utilities such as fail2ban)
          "~* /(?:uploads|files)/.*\\.php$" = {
            extraConfig = ''
              deny all;
            '';
          };
          "~ \\.php$" = {
            extraConfig = ''
              fastcgi_intercept_errors on;
              fastcgi_pass unix:${config.services.wordpress-nbhwj.sockets.phpfpm};
            '';
          };
          "~* \\.(js|css|png|jpg|jpeg|gif|ico)$" = {
            extraConfig = ''
              valid_referers ${toString config.services.wordpress-nbhwj.domains};
              if ($invalid_referer) {
                return 403;
              }

              add_header Vary Accept;
            '';
          };
        };
        extraConfig = ''
          add_header Strict-Transport-Security "max-age=63072000" always;
          add_header Alt-Svc 'h3=":$server_port"; ma=2592000';
          if ($server_name != "${mainDomain}") {
            return 301 https://${mainDomain}$request_uri;
          }
        '';
      };
    };
    services.redis.servers.wordpress-nbhwj = {
      enable = true;
      inherit (config.services.wordpress-nbhwj) user;
      group = config.users.users.${config.services.wordpress-nbhwj.user}.group;
    };
  };
}
