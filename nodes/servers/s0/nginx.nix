{ config, ... }:
let
  mainUnix = "/run/nginx/main.sock";
in
{
  services.nginx = {
    preread.upstreams = {
      ${config.services.networking.domain} = "unix:${mainUnix}";
    };
    virtualHosts.${config.networking.domain} = {
      listen = [
        {
          addr = "unix:${mainUnix}";
          mode = "ssl";
        }
        {
          addr = "[::]";
          port = 443;
          mode = "quic";
        }
        {
          addr = "*";
          port = 443;
          mode = "quic";
        }
        {
          addr = "[::]";
          port = 80;
        }
        {
          addr = "*";
          port = 80;
        }
      ];
      forceSSL = true;
      enableACME = true;
      extraConfig = ''
        add_header Strict-Transport-Security "max-age=63072000" always;
        add_header Alt-Svc 'h3=":$server_port"; ma=2592000';
      '';
    };
  };
}
