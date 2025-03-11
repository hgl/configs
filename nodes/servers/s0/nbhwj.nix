{ pkgs, config, ... }:
let
  user = "wordpress-nbhwj";
  dbName = user;
  domain = "nbhwj.com";
in
{
  services.mysql = {
    enable = true;
    ensureDatabases = [ dbName ];
    ensureUsers = [
      {
        name = user;
        ensurePermissions = {
          "\\`${dbName}\\`.*" = "ALL PRIVILEGES";
        };
      }
    ];
  };
  users.users.${user} = {
    group = config.services.caddy.group;
    isSystemUser = true;
  };
  services.phpfpm.pools.wordpress-nbhwj = {
    inherit user;
    group = config.services.caddy.group;
    phpPackage = pkgs.php84.withExtensions (
      { enabled, all }:
      enabled
      ++ (with all; [
        imagick
        apcu
      ])
    );
    settings = {
      "listen.owner" = config.services.caddy.user;
      "listen.group" = config.services.caddy.group;
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
    "d /srv/www/wordpress/nbhwj - ${user} ${config.users.users.${user}.group}"
  ];
  services.caddy = {
    enable = true;
    virtualHosts = {
      ${domain} = {
        useACMEHost = domain;
        extraConfig = ''
          header -Server
          root /srv/www/wordpress/nbhwj
          file_server
          encode gzip zstd

          @cache {
            not header_regexp Cookie "comment_author|wordpress_[a-f0-9]+|wp-postpass|wordpress_logged_in"
            not path_regexp "(/wp-admin/|/xmlrpc.php|/wp-(app|cron|login|register|mail).php|wp-.*.php|/feed/|index.php|wp-comments-popup.php|wp-links-opml.php|wp-locations.php|sitemap(index)?.xml|[a-z0-9-]+-sitemap([0-9]+)?.xml)"
            not method POST
            not expression {query} != '''
          }
          route @cache {
            try_files /wp-content/cache/supercache/{host}{uri}/index-https.html /wp-content/cache/supercache/{host}{uri}/index.html {path} {path}/index.php?{query}
          }

          @disallowed {
            path /xmlrpc.php
            path *.sql
            path /wp-content/uploads/*.php
          }
          rewrite @disallowed /

          php_fastcgi unix/${config.services.phpfpm.pools.wordpress-nbhwj.socket}
        '';
      };
      "www.${domain}" = {
        useACMEHost = "www.${domain}";
        extraConfig = ''
          header -Server
          redir https://${domain}{uri} 301
        '';
      };
    };
  };
  services.redis.servers.wordpress-nbhwj = {
    enable = true;
    inherit user;
    group = config.users.users.${user}.group;
  };
}
