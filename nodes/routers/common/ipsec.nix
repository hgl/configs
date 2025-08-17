{
  lib,
  config,
  pkgs',
  nodes,
  privatePath,
  ...
}:
let
  xfrmInterfaces = lib.filterAttrs (_: interface: interface.type == "xfrm") config.router.interfaces;
in
{
  services.strongswan-swanctl = {
    enable = true;
    package = pkgs'.strongswan;
    swanctl = {
      connections = lib.mapAttrs (_: interface: {
        version = 2;
        if_id_in = toString interface.xfrmId;
        if_id_out = toString interface.xfrmId;
        pools = [
          "${interface.name}v6"
          "${interface.name}"
        ];
        proposals = [
          "aes128gcm16-prfsha256-curve25519"
          "aes128gcm16-prfsha256-ecp256"
        ];
        local.default = {
          auth = "pubkey";
          id = config.networking.fqdn;
        };
        remote.default = {
          auth = "pubkey";
          id = "*.${interface.name}";
        };
        children.default = {
          local_ts = [
            "0.0.0.0/0"
            "::/0"
          ];
          esp_proposals = [
            "aes128gcm16-curve25519"
            "aes128gcm16-ecp256"
          ];
        };
      }) xfrmInterfaces;
      pools = lib.concatMapAttrs (_: interface: {
        "${interface.name}v6" = {
          addrs = "${interface.ipv6 {
            interfaceId = 2;
            prefixLength = 120;
          }}";
          dns = [ (interface.ipv6 { interfaceId = 1; }) ];
        };
        ${interface.name} = {
          addrs = "${interface.poolv4.startIp}-${interface.poolv4.endIp}";
          dns = [ (interface.ipv4 { hostId = 1; }) ];
        };
      }) xfrmInterfaces;
    };
  };

  systemd.services.strongswan-swanctl = {
    # nixpkgs' definition includes a lot of not needed dependencies here
    path = lib.mkForce [ ];
  };

  sops.secrets."ipsec-server.key" = {
    sopsFile = "${nodes.current.privatePath}/vpn/ipsec/server.key";
    format = "binary";
  };
  environment.etc = {
    "swanctl/ecdsa/server.key".source = config.sops.secrets."ipsec-server.key".path;
    "swanctl/x509/server.crt".source = "${nodes.current.privatePath}/vpn/ipsec/server.crt";
    "swanctl/x509ca/ca.crt".source = "${privatePath}/vpn/ipsec/ca.crt";
  }
  // lib.optionalAttrs (lib.pathExists "${privatePath}/vpn/ipsec/clients.crl") {
    "swanctl/x509crl/clients.crl".source = "${privatePath}/vpn/ipsec/clients.crl";
  };

  router.interfaces.wan.nftables.chains.filter.input.filter = ''
    udp dport 500 accept comment "Allow ISAKMP"
    udp dport 4500 accept comment "Allow IPsec NAT-T"
    meta l4proto esp accept comment "Allow ESP"
  '';
}
