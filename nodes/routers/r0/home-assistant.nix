{
  lib,
  lib',
  pkgs,
  config,
  ...
}:
let
  serverName = "ha";
in
{
  services.home-assistant = {
    enable = true;
    config = {
      http = {
        server_host = [ "::1" ];
        use_x_forwarded_for = true;
        trusted_proxies = "::1";
      };
      default_config = { };
      homeassistant = {
        latitude = 29.832942890282826;
        longitude = 121.59383115334553;
        radius = 100;
        internal_url = "http://${serverName}";
        unit_system = "metric";
        currency = "USD";
        country = "CN";
        temperature_unit = "C";
        time_zone = config.time.timeZone;
        debug = true;
      };
      homekit = { };
    };
    extraComponents = [
      "default_config"
      "google_translate"
      "met"
      "isal"
      "thread"
      "homekit"
      "homekit_controller"
      "apple_tv"
      "androidtv"
      "androidtv_remote"
      "ipp"
      "synology_dsm"
      "cast"
    ];
    extraPackages =
      ppkgs: with ppkgs; [
      ];
    customComponents = with pkgs.home-assistant-custom-components; [
      xiaomi_home
    ];
  };

  # Needed to address error raised by xiaomi_home
  # https://github.com/NixOS/nixpkgs/issues/383276#issuecomment-2693243293
  systemd.services.home-assistant.serviceConfig.SystemCallFilter = [
    "capset"
    "setuid"
  ];

  networkd.hostNameAliases = [ serverName ];

  services.nginx.virtualHosts.${serverName} = {
    listen = [
      {
        addr = "[::]";
        port = 80;
      }
    ];
    locations."/" = {
      proxyPass =
        "http://"
        + lib'.addressPortString {
          address = lib.head config.services.home-assistant.config.http.server_host;
          port = config.services.home-assistant.config.http.server_port;
        };
      recommendedProxySettings = true;
      extraConfig = ''
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
      '';
    };
  };
}
