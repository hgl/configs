{
  config,
  ...
}:
{
  sops.secrets.ddnsCloudflareToken = { };

  services.ddclient = {
    enable = true;
    interval = "5min";
    usev4 = "ifv4, ifv4=${config.networkd.interfaces.wan.name}";
    usev6 = "ifv6, ifv6=${config.networkd.interfaces.wan.name}";
    protocol = "cloudflare";
    domains = [ config.networking.fqdn ];
    zone = config.networking.domain;
    passwordFile = config.sops.secrets.ddnsCloudflareToken.path;
  };
}
