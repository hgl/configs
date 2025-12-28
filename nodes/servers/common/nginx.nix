{
  config,
  ...
}:
{
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

    commonHttpConfig = ''
      set_real_ip_from ::1;
      real_ip_header proxy_protocol;
    '';

    virtualHosts = {
      host = {
        serverName = config.networking.fqdn;
        root = "/srv/www/host";
        forceSSL = true;
        enableACME = true;
        reuseport = true;
        default = true;
        extraConfig = ''
          add_header Strict-Transport-Security "max-age=63072000" always;
          add_header Alt-Svc 'h3=":$server_port"; ma=2592000';
        '';
      };
      main = {
        serverName = config.networking.domain;
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
    "d ${config.services.nginx.virtualHosts.host.root} - ${config.services.nginx.user} ${config.services.nginx.group}"
  ];
}
