{
  config,
  pkgs,
  ...
}:
{
  services.nginx = {
    enable = true;
    package = pkgs.nginxQuic;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    recommendedGzipSettings = true;
    recommendedBrotliSettings = true;
    recommendedZstdSettings = true;
    defaultListen = [
      {
        addr = "[::]";
        port = 2;
        ssl = true;
      }
      {
        addr = "*";
        port = 2;
        ssl = true;
      }
      {
        addr = "[::]";
        port = 443;
        ssl = true;
      }
      {
        addr = "*";
        port = 443;
        ssl = true;
      }
      {
        addr = "[::]";
        port = 3;
        ssl = false;
      }
      {
        addr = "*";
        port = 3;
        ssl = false;
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
      http = {
        serverName = "_";
        default = true;
        extraConfig = ''
          if ($server_port = 3) {
            return 301 https://$host:2$request_uri;
          }
          if ($server_port = 80) {
            return 301 https://$host$request_uri;
          }
        '';
      };
      ${config.networking.fqdn} = {
        root = "/srv/www";
        quic = true;
        onlySSL = true;
        enableACME = true;
        acmeRoot = null;
        extraConfig = ''
          add_header Strict-Transport-Security "max-age=63072000" always;
        '';
      };
    };
  };

  sops.secrets.acmeCloudflareToken = { };
  security.acme.certs.${config.networking.fqdn} = {
    dnsProvider = "cloudflare";
    credentialFiles = {
      CF_DNS_API_TOKEN_FILE = config.sops.secrets.acmeCloudflareToken.path;
    };
    group = config.services.nginx.group;
  };

  networking.wan = {
    allowedTraffics = [
      {
        destination.ports = [
          2
          3
          443
          80
        ];
      }
    ];
  };
}
