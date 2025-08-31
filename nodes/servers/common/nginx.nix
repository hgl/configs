{
  config,
  pkgs,
  modules',
  ...
}:
{
  imports = [
    modules'.nginx-preread
  ];

  security.acme = {
    acceptTerms = true;
    defaults = {
      webroot = "/var/lib/acme/acme-challenge";
    };
  };

  services.nginx = {
    enable = true;
    package = pkgs.nginxQuic;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    recommendedGzipSettings = true;
    recommendedBrotliSettings = true;

    preread = {
      enable = true;
      upstreams = {
        default = "[::1]:444";
      };
    };

    defaultListen = [
      {
        addr = "[::1]";
        port = 444;
        ssl = true;
      }
      {
        addr = "[::]";
        port = 80;
        ssl = false;
      }
      {
        addr = "*";
        port = 80;
        ssl = false;
      }
    ];
    virtualHosts = {
      ${config.networking.fqdn} = {
        root = "/srv/www/host";
        quic = true;
        forceSSL = true;
        enableACME = true;
        extraConfig = ''
          add_header Strict-Transport-Security "max-age=63072000" always;
          add_header Alt-Svc 'h3=":$server_port"; ma=2592000';
        '';
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d /srv/www/host - ${config.services.nginx.user} ${config.services.nginx.group}"
  ];
}
