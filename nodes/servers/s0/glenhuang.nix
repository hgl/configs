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
        handle /* {
          root /srv/www/glenhuang
          try_files {path}.html
          file_server
        }
      '';
    };
  };
}
