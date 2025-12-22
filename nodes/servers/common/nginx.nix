{
  config,
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
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    recommendedGzipSettings = true;
    recommendedBrotliSettings = true;
    experimentalZstdSettings = true;

    preread = {
      enable = true;
      upstreams = {
        default = "unix:/run/nginx/host.sock";
        ${config.networking.domain} = "unix:/run/nginx/main.sock";
      };
    };

    virtualHosts = {
      http = {
        listen = [
          {
            addr = "[::]";
            port = 80;
          }
          {
            addr = "*";
            port = 80;
          }
        ];
        serverName = "\"\"";
        default = true;
        extraConfig = ''
          return 301 https://$host$request_uri;
        '';
      };
      host = {
        serverName = config.networking.fqdn;
        listen = [
          {
            addr = config.services.nginx.preread.upstreams.default;
            ssl = true;
          }
        ];
        root = "/srv/www/host";
        onlySSL = true;
        enableACME = true;
        # reuseport = true;
        default = true;
        extraConfig = ''
          add_header Strict-Transport-Security "max-age=63072000" always;
          add_header Alt-Svc 'h3=":$server_port"; ma=2592000';
        '';
      };
      main = {
        serverName = config.networking.domain;
        listen = [
          {
            addr = config.services.nginx.preread.upstreams.${config.networking.domain};
            ssl = true;
          }
        ];
        onlySSL = true;
        enableACME = true;
        extraConfig = ''
          add_header Strict-Transport-Security "max-age=63072000" always;
          add_header Alt-Svc 'h3=":$server_port"; ma=2592000';
        '';
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d ${config.services.nginx.virtualHosts.host.root} - ${config.services.nginx.user} ${config.services.nginx.group}"
  ];
}
