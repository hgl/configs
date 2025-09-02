{ config, ... }:
{
  services.nginx = {
    preread.upstreams = {
      ${config.networking.domain} = "unix:/run/nginx/main.sock";
    };
    virtualHosts.${config.networking.domain} = {
      listen = [
        {
          addr = config.services.nginx.preread.upstreams.${config.networking.domain};
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
