{ lib, config, ... }:
let
  cfg = config.services.nginx.preread;
  inherit (lib) types;
in
{
  options.services.nginx.preread = {
    enable = lib.mkEnableOption "preread servers";
    upstreams = lib.mkOption {
      type = types.submodule {
        freeformType = types.attrsOf types.nonEmptyStr;
        options.default = lib.mkOption {
          type = types.nonEmptyStr;
        };
      };
      default = { };
    };
  };

  config = lib.mkIf cfg.enable {
    services.nginx.streamConfig = ''
      map $ssl_preread_server_name $upstream {
        ${lib.concatLines (
          lib.mapAttrsToList (
            serverName: upstream: "${serverName} ${upstream};"
          ) config.services.nginx.preread.upstreams
        )}
      }

      server {
        listen 443;
        listen [::]:443;

        ssl_preread on;
        proxy_pass $upstream;
      }
    '';
  };
}
