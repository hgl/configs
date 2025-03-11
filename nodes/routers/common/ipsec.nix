{
  lib,
  config,
  pkgs',
  nodes,
  privatePath,
  ...
}:
let
  userXfrmId = 1;
  guestXfrmId = 2;
in
{
  services.strongswan-swanctl = {
    enable = true;
    includes = [ "/var/lib/strongswan/*.conf" ];
    package = pkgs'.strongswan;
    swanctl = {
      connections = {
        user = {
          version = 2;
          if_id_in = toString userXfrmId;
          if_id_out = toString userXfrmId;
          pools = [
            "local4"
            "local6"
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
            id = "*.user";
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
        guest = {
          version = 2;
          if_id_in = toString guestXfrmId;
          if_id_out = toString guestXfrmId;
          pools = [
            "guest_local4"
            "guest_local6"
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
            id = "*.guest";
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
      };
      pools = {
        local6 = {
          addrs = "${
            nodes.current.interfaces.ipsec.ipv6 {
              suffix = nodes.current.dhcp.pool.start;
              cidr = false;
            }
          }-${
            nodes.current.interfaces.ipsec.ipv6 {
              suffix = nodes.current.dhcp.pool.end;
              cidr = false;
            }
          }";
          dns = [ (nodes.current.interfaces.ipsec.ipv6 { cidr = false; }) ];
        };
        local4 = {
          addrs = "${
            nodes.current.interfaces.ipsec.ipv4 {
              suffix = nodes.current.dhcp.pool.start;
              cidr = false;
            }
          }-${
            nodes.current.interfaces.ipsec.ipv4 {
              suffix = nodes.current.dhcp.pool.end;
              cidr = false;
            }
          }";
          dns = [ (nodes.current.interfaces.ipsec.ipv4 { cidr = false; }) ];
        };
        guest_local6 = {
          addrs = "${
            nodes.current.interfaces.guest-ipsec.ipv6 {
              suffix = nodes.current.dhcp.pool.start;
              cidr = false;
            }
          }-${
            nodes.current.interfaces.guest-ipsec.ipv6 {
              suffix = nodes.current.dhcp.pool.end;
              cidr = false;
            }
          }";
          dns = [ (nodes.current.interfaces.guest-ipsec.ipv6 { cidr = false; }) ];
        };
        guest_local4 = {
          addrs = "${
            nodes.current.interfaces.guest-ipsec.ipv4 {
              suffix = nodes.current.dhcp.pool.start;
              cidr = false;
            }
          }-${
            nodes.current.interfaces.guest-ipsec.ipv4 {
              suffix = nodes.current.dhcp.pool.end;
              cidr = false;
            }
          }";
          dns = [ (nodes.current.interfaces.guest-ipsec.ipv4 { cidr = false; }) ];
        };
      };
    };
  };

  systemd.services.strongswan-swanctl = {
    # nixpkgs' definition includes a lot of not needed dependencies here
    path = lib.mkForce [ ];
  };

  systemd.network = {
    netdevs = {
      "20-ipsec" = {
        netdevConfig = {
          Name = "ipsec";
          Kind = "xfrm";
        };
        xfrmConfig = {
          InterfaceId = userXfrmId;
        };
      };
      "20-guest-ipsec" = {
        netdevConfig = {
          Name = "guest-ipsec";
          Kind = "xfrm";
        };
        xfrmConfig = {
          InterfaceId = guestXfrmId;
        };
      };
    };
    networks = {
      "20-ipsec-link" = {
        matchConfig = {
          Name = "lo";
        };
        networkConfig = {
          Xfrm = [
            "ipsec"
            "guest-ipsec"
          ];
        };
      };
      "20-ipsec" = {
        matchConfig = {
          Name = "ipsec";
        };
        networkConfig = {
          Address = [
            (nodes.current.interfaces.ipsec.ipv6 { cidr = true; })
            (nodes.current.interfaces.ipsec.ipv4 { cidr = true; })
          ];
          IPv6AcceptRA = false;
          IPv6SendRA = false;
        };
      };
      "20-guest-ipsec" = {
        matchConfig = {
          Name = "guest-ipsec";
        };
        networkConfig = {
          Address = [
            (nodes.current.interfaces.guest-ipsec.ipv6 { cidr = true; })
            (nodes.current.interfaces.guest-ipsec.ipv4 { cidr = true; })
          ];
          IPv6AcceptRA = false;
          IPv6SendRA = false;
        };
      };
    };
  };

  sops.secrets."ipsec-server.key" = {
    sopsFile = "${privatePath}/nodes/routers/${nodes.current.name}/vpn/ipsec/server.key";
    format = "binary";
  };
  environment.etc =
    {
      "swanctl/ecdsa/server.key".source = config.sops.secrets."ipsec-server.key".path;
      "swanctl/x509/server.crt".source =
        "${privatePath}/nodes/routers/${nodes.current.name}/ipsec/server.${lib.optionalString nodes.current.subrouter "sub."}crt";
      "swanctl/x509ca/ca.crt".source = "${privatePath}/vpn/ipsec/ca.crt";
    }
    // lib.optionalAttrs (lib.pathExists "${privatePath}/vpn/ipsec/clients.crl") {
      "swanctl/x509crl/clients.crl".source = "${privatePath}/vpn/ipsec/clients.crl";
    };
  networking.wan = {
    allowedTraffics = [
      {
        protocols = [ "udp" ];
        destination.ports = [
          500
          4500
        ];
      }
      {
        protocols = [ "esp" ];
      }
    ];
    npt = [
      (nodes.current.interfaces.ipsec.ipv6 { cidr = true; })
      (nodes.current.interfaces.guest-ipsec.ipv6 { cidr = true; })
    ];
  };

  # cannot use ipsec as the table name, because it's a keyword in nft syntax
  networking.nftables.tables.ipsec-vpn = {
    family = "inet";
    content = ''
      chain input {
        type filter hook input priority filter;
        iifname "guest-ipsec" jump input-guest-ipsec
      }
      chain input-guest-ipsec {
        ct state vmap { established : accept, related : accept }
        fib daddr type { broadcast, multicast } accept
        ip daddr != ${nodes.current.interfaces.guest-ipsec.ipv4 { cidr = false; }} drop
        ip6 daddr & ::ffff:ffff:ffff:ffff:ffff != 0:0:0:${toString nodes.current.interfaces.guest-ipsec.subnetId}::1 drop
        icmp type echo-request accept comment "Allow Ping"
        meta nfproto ipv4 meta l4proto igmp accept comment "Allow IGMP"
        ip6 saddr fe80::/10 icmpv6 type . icmpv6 code { mld-listener-query . 0, mld-listener-report . 0, mld-listener-done . 0, mld2-listener-report . 0 } accept comment "Allow MLD"
        icmpv6 type { destination-unreachable, time-exceeded, echo-request, echo-reply, nd-router-solicit, nd-router-advert } limit rate 1000/second burst 5 packets accept comment "Allow ICMPv6-Input"
        icmpv6 type . icmpv6 code { packet-too-big . 0, parameter-problem . 0, nd-neighbor-solicit . 0, nd-neighbor-advert . 0, parameter-problem . 1 } limit rate 1000/second burst 5 packets accept comment "Allow ICMPv6 Input"
        udp dport 53 accept comment "Allow DNS"
        drop
      }

      chain forward {
        type filter hook forward priority filter;
        iifname "guest-ipsec" jump forward-guest-ipsec
      }
      chain forward-guest-ipsec {
        ct state vmap { established : accept, related : accept }
        oifname { "y", "wan" } accept
        drop
      }
    '';
  };
}
