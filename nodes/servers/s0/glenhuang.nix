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
        handle_path /resume {
          file_server {
            root /srv/www/glenhuang/resume/index.html
          }
        }
        redir /resume/ /resume 301
        handle_path /resume/* {
          root /srv/www/glenhuang/resume
          file_server {
            index ""
            hide index.html
          }
        }
      '';
    };
  };
}
