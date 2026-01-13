{ config, ... }:
{
  services.nginx.virtualHosts.main = {
    serverName = config.networking.domain;
    forceSSL = true;
    enableACME = true;
    extraConfig = ''
      add_header Strict-Transport-Security "max-age=63072000" always;
      add_header Alt-Svc 'h3=":$server_port"; ma=2592000';
    '';
  };
}
