let
  domain = "glenhuang.com";
in
{
  services.caddy.virtualHosts = {
    ${domain} = {
      useACMEHost = domain;
      extraConfig = ''
        header {
          -Server
          Strict-Transport-Security max-age=63072000
        }
        root /srv/www/glenhuang
        file_server
        encode gzip zstd
        try_files {path} {path}/index.html =404
        @pathWithSlash path_regexp dir (.+)/$
        handle @pathWithSlash {
          @htmlFileExists file {re.dir.1}/index.html
          redir @htmlFileExists {re.dir.1}?{query} permanent
        }
      '';
    };
  };
}
