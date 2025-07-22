{
  lib,
  config,
  pkgs',
  nodes,
  privatePath,
  ...
}:
let
  concatMapXfrmAttrs = config.router.concatMapInterfaceAttrs ({ type, ... }: type == "xfrm");
in
{
  router.interfaces = {
    ipsec = {
      type = "xfrm";
      subnetId = 10;
      xfrmId = 1;
    };
    guest-ipsec = {
      type = "xfrm";
      subnetId = 11;
      xfrmId = 2;
      quarantine = {
        enable = true;
      };
    };
  };
  services.strongswan-swanctl = {
    enable = true;
    package = pkgs'.strongswan;
    swanctl = {
      connections = concatMapXfrmAttrs (interface: {
        ${interface.name} = {
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
        };
      });
      pools = concatMapXfrmAttrs (interface: {
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
      });
    };
  };

  systemd.services.strongswan-swanctl = {
    # nixpkgs' definition includes a lot of not needed dependencies here
    path = lib.mkForce [ ];
  };

  sops.secrets."ipsec-server.key" = {
    sopsFile = "${privatePath}/nodes/routers/${nodes.current.name}/vpn/ipsec/server.key";
    format = "binary";
  };
  environment.etc =
    {
      "swanctl/ecdsa/server.key".source = config.sops.secrets."ipsec-server.key".path;
      "swanctl/x509/server.crt".source =
        "${privatePath}/nodes/routers/${nodes.current.name}/vpn/ipsec/server.crt";
      "swanctl/x509ca/ca.crt".source = "${privatePath}/vpn/ipsec/ca.crt";
    }
    // lib.optionalAttrs (lib.pathExists "${privatePath}/vpn/ipsec/clients.crl") {
      "swanctl/x509crl/clients.crl".source = "${privatePath}/vpn/ipsec/clients.crl";
    };

  router.interfaces.wan.nftables.inputChain = ''
    udp dport 500 accept comment "Allow ISAKMP"
    udp dport 4500 accept comment "Allow IPsec NAT-T"
    meta l4proto esp accept comment "Allow ESP"
  '';
}
