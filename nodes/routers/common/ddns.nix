{
  config,
  ...
}:
{
  sops.secrets = {
    ddnsCloudflareZoneId = { };
    ddnsCloudflareToken = { };
  };
  router.interfaces.wan.ddns = [
    {
      domains = [ config.networking.fqdn ];
      provider = {
        type = "cloudflare";
        zoneIdFile = config.sops.secrets.ddnsCloudflareZoneId.path;
        apiTokenFile = config.sops.secrets.ddnsCloudflareToken.path;
      };
    }
  ];
}
