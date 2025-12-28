{
  lib',
  pkgs,
  config,
  ...
}:
let
  domain = "glenhuang.com";
  delegatedDomain = "matrix.${domain}";
  port = 8448;
in
{
  sops = {
    secrets."matrix/registrationSharedSecret" = { };
    templates."matrix/registrationSharedSecret" = {
      owner = "matrix-synapse";
      content = ''
        registration_shared_secret: ${config.sops.placeholder."matrix/registrationSharedSecret"}
      '';
    };
  };

  services.matrix-synapse = {
    enable = true;
    settings = {
      server_name = domain;
      public_baseurl = "https://${delegatedDomain}";
      listeners = [
        {
          inherit port;
          bind_addresses = [ "::1" ];
          type = "http";
          tls = false;
          x_forwarded = true;
          resources = [
            {
              names = [
                "client"
                "federation"
              ];
              compress = true;
            }
          ];
        }
      ];
    };
    extraConfigFiles = [ config.sops.templates."matrix/registrationSharedSecret".path ];
  };
  services.postgresql = {
    enable = true;
    ensureDatabases = [ "matrix-synapse" ];
    ensureUsers = [
      {
        name = "matrix-synapse";
        ensureDBOwnership = true;
      }
    ];
  };
  services.nginx = {
    virtualHosts.matrix = {
      serverName = delegatedDomain;
      forceSSL = true;
      enableACME = true;
      locations = {
        "/" = {
          extraConfig = ''
            return 404;
          '';
        };
        "/_matrix" = {
          proxyPass = "http://${
            lib'.addressPortString {
              address = "::1";
              inherit port;
            }
          }";
        };
        "/_synapse/client" = {
          proxyPass = "http://${
            lib'.addressPortString {
              address = "::1";
              inherit port;
            }
          }";
        };
      };
    };
  };
  environment.systemPackages = with pkgs; [
    matrix-synapse
  ];
}
