{
  config,
  modules',
  ...
}:
{
  imports = [
    modules'.ddns
  ];
  sops.secrets = {
    ddnsCloudflareZoneId = { };
    ddnsCloudflareToken = { };
  };
  services.ddns = {
    enable = true;
    cloudflare = {
      zoneIdFile = config.sops.secrets.ddnsCloudflareZoneId.path;
      apiTokenFile = config.sops.secrets.ddnsCloudflareToken.path;
    };
    domains = {
      ${config.networking.fqdn} = {
        interface = "wan";
      };
    };
  };
}
