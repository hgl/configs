{ config, nodes, ... }:
let
  domain = "nextcloud.${config.networking.domain}";
in
{
  services.nginx.virtualHosts = {
    ${domain} = {
      quic = true;
      onlySSL = true;
      enableACME = true;
      acmeRoot = null;
      locations."/" = {
        recommendedProxySettings = true;
        proxyWebsockets = true;
        proxyPass = "http://${nodes.current.devices.nas.ipv4.lan { cidr = false; }}:8080";
        extraConfig = ''
          proxy_request_buffering off;
          client_max_body_size 0;
          add_header Strict-Transport-Security "max-age=63072000" always;
        '';
      };
    };
  };

  sops.secrets.acmeCloudflareToken = { };
  security.acme.certs.${domain} = {
    dnsProvider = "cloudflare";
    credentialFiles = {
      CF_DNS_API_TOKEN_FILE = config.sops.secrets.acmeCloudflareToken.path;
    };
    group = config.services.nginx.group;
  };
}
