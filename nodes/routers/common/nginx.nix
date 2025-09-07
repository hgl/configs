{
  modules',
  config,
  pkgs,
  ...
}:
{
  imports = [
    modules'.nginx
  ];
  services.nginx = {
    enable = true;
    package = pkgs.nginxQuic;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    recommendedGzipSettings = true;
    recommendedBrotliSettings = true;
    experimentalZstdSettings = true;
    defaultListen = [
      {
        addr = "[::]";
        port = 2;
        mode = "ssl";
      }
      {
        addr = "*";
        port = 2;
        mode = "ssl";
      }
      {
        addr = "[::]";
        port = 2;
        mode = "quic";
      }
      {
        addr = "*";
        port = 2;
        mode = "quic";
      }
      {
        addr = "[::]";
        port = 443;
        mode = "ssl";
      }
      {
        addr = "*";
        port = 443;
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
        port = 3;
      }
      {
        addr = "*";
        port = 3;
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
    commonHttpConfig = ''
      map $server_port $https_port {
        3 2;
        80 443;
      }
    '';
    virtualHosts = {
      http = {
        listen = [
          {
            addr = "[::]";
            port = 3;
          }
          {
            addr = "*";
            port = 3;
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
        serverName = "\"\"";
        default = true;
        extraConfig = ''
          return 301 https://$host:$https_port$request_uri;
        '';
      };
      ${config.networking.fqdn} = {
        root = "/srv/www";
        onlySSL = true;
        enableACME = true;
        acmeRoot = null;
        extraConfig = ''
          add_header Strict-Transport-Security "max-age=63072000" always;
          add_header Alt-Svc 'h3=":$server_port"; ma=2592000';
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

  networkd.interfaces.wan.nftables.chains.filter.input.filter = ''
    meta l4proto { tcp, udp } th dport { 2, 3, 443, 80 } accept comment "Allow HTTP(S)"
  '';
}
