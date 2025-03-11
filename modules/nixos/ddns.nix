{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.ddns;
  update-ddns =
    ipVer: domain: props:
    let
      zoneIdFile =
        if props.cloudflare.zoneIdFile == null then
          cfg.cloudflare.zoneIdFile
        else
          props.cloudflare.zoneIdFile;
      zoneId = if props.cloudflare.zoneId == "" then cfg.cloudflare.zoneId else props.cloudflare.zoneId;
      name = "update-ddns-ipv${toString ipVer}-${domain}";
    in
    assert lib.assertMsg (
      zoneId != "" || zoneIdFile != null
    ) "Either zoneId or zoneIdFile must be non-empty";
    lib.getExe (
      pkgs.writeShellApplication {
        inherit name;
        runtimeInputs = with pkgs; [
          coreutils
          curl
          jq
        ];
        text = ''
          first() {
            echo "''${1-}"
          }
          # shellcheck disable=SC2086
          ip=$(first ''${IPV${toString ipVer}_ADDRS-})
          if [[ -z $ip ]]; then
            exit
          fi
          ip=''${ip%/*}
          ${if zoneId != "" then "zoneId='${zoneId}'" else "zoneId=$(< '${zoneIdFile}')"}
          token=$(cat ${cfg.cloudflare.apiTokenFile})
          recordId=$(
            curl --disable --fail --silent --show-error --location \
              --max-time 10 --retry 10 --retry-delay 3 \
              --request GET \
              --url "https://api.cloudflare.com/client/v4/zones/$zoneId/dns_records" \
              --header 'Content-Type: application/json' \
              --header "Authorization: Bearer $token" |
              jq --raw-output --arg d ${domain} \
              'first(.result[] | select(.type == "${if ipVer == 6 then "AAAA" else "A"}" and .name == $d)).id'
          )
          curl --disable --fail --silent --show-error --location \
            --max-time 10 --retry 10 --retry-delay 3 \
            --request PATCH \
            --url "https://api.cloudflare.com/client/v4/zones/$zoneId/dns_records/$recordId" \
            --header 'Content-Type: application/json' \
            --header "Authorization: Bearer $token" \
            --data "{\"content\": \"$ip\"}"
        '';
      }
    );
in
{
  options =
    with lib;
    with types;
    {
      services.ddns = {
        enable = mkEnableOption "ddns";
        cloudflare = {
          apiTokenFile = mkOption {
            type = path;
          };
          zoneId = mkOption {
            type = str;
            default = "";
          };
          zoneIdFile = mkOption {
            type = nullOr path;
            default = null;
          };
        };
        domains = mkOption {
          type = attrsOf (submodule {
            options = {
              interface = mkOption {
                type = str;
              };
              ipv6 = mkOption {
                type = bool;
                default = true;
              };
              ipv4 = mkOption {
                type = bool;
                default = true;
              };
              cloudflare = {
                zoneId = mkOption {
                  type = str;
                  default = "";
                };
                zoneIdFile = mkOption {
                  type = nullOr path;
                  default = null;
                };
              };
            };
          });
        };
      };
    };
  config = lib.mkIf cfg.enable {
    services.ipmon = {
      enable = true;
      rules = lib.concatMapAttrs (
        domain: props:
        lib.optionalAttrs props.ipv6 {
          "ddns-ipv6-${domain}" = {
            interfaces = [ props.interface ];
            watch = [ "IPV6_ADDRS" ];
            script = update-ddns 6 domain props;
          };
        }
        // lib.optionalAttrs props.ipv4 {
          "ddns-ipv4-${domain}" = {
            interfaces = [ props.interface ];
            watch = [ "IPV4_ADDRS" ];
            script = update-ddns 4 domain props;
          };
        }
      ) cfg.domains;
    };
  };
}
