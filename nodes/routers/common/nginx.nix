{
  config,
  ...
}:
{
  services.nginx = {
    enable = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    recommendedGzipSettings = true;
    recommendedBrotliSettings = true;
    experimentalZstdSettings = true;

    # By default, a vhost should listen to https both internal and public
    defaultListen = [
      {
        addr = "[::]";
        port = 2;
        ssl = true;
        extraParameters = [ "ipv6only=off" ];
      }
      {
        addr = "[::]";
        port = 443;
        ssl = true;
        extraParameters = [ "ipv6only=off" ];
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
            extraParameters = [ "ipv6only=off" ];
          }
          {
            addr = "[::]";
            port = 80;
            extraParameters = [ "ipv6only=off" ];
          }
        ];
        serverName = "\"\"";
        default = true;
        extraConfig = ''
          return 301 https://$host:$https_port$request_uri;
        '';
      };
      host = {
        serverName = config.networking.fqdn;
        root = "/srv/www";
        onlySSL = true;
        quic = true;
        enableACME = true;
        default = true;
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
