{
  lib,
  lib',
  nodes,
  ...
}:
{
  systemd.network = {
    enable = true;
    netdevs =
      {
        "10-lan" = {
          netdevConfig = {
            Name = "lan";
            Kind = "bridge";
            MACAddress = "none";
          };
        };
        "10-guest-lan" = {
          netdevConfig = {
            Name = "guest-lan";
            Kind = "bridge";
          };
        };
      }
      // lib'.mapListToAttrs (
        port:
        let
          inherit (nodes.current.interfaces.guest-lan) vlanId;
          name = "${port}.${toString vlanId}";
        in
        lib.nameValuePair "10-${name}" {
          netdevConfig = {
            Name = name;
            Kind = "vlan";
          };
          vlanConfig = {
            Id = vlanId;
          };
        }
      ) nodes.current.interfaces.lan.ports;
    links = {
      "10-lan" = {
        matchConfig = {
          OriginalName = "lan";
        };
        linkConfig = {
          MACAddressPolicy = "none";
        };
      };
    };
    networks =
      {
        "10-lan" = {
          matchConfig = {
            Name = "lan";
          };
          networkConfig = {
            Address = [
              (nodes.current.interfaces.lan.ipv6 { cidr = true; })
              (nodes.current.interfaces.lan.ipv4 { cidr = true; })
            ];
            IPv6AcceptRA = false;
            IPv6SendRA = false;
            DHCPPrefixDelegation = true;
          };
          dhcpPrefixDelegationConfig = {
            SubnetId = nodes.current.interfaces.lan.subnetId;
            Token = "static:::1";
          };
        };
        "10-guest-lan-ports" = {
          matchConfig = {
            Name = toString (
              map (
                port: "${port}.${toString nodes.current.interfaces.guest-lan.vlanId}"
              ) nodes.current.interfaces.lan.ports
            );
          };
          networkConfig = {
            Bridge = "guest-lan";
          };
        };
        "10-guest-lan" = {
          matchConfig = {
            Name = "guest-lan";
          };
          networkConfig = {
            Address = [
              (nodes.current.interfaces.guest-lan.ipv6 { cidr = true; })
              (nodes.current.interfaces.guest-lan.ipv4 { cidr = true; })
            ];
            IPv6AcceptRA = false;
            IPv6SendRA = false;
            DHCPPrefixDelegation = true;
          };
          dhcpPrefixDelegationConfig = {
            SubnetId = nodes.current.interfaces.guest-lan.subnetId;
            Token = "static:::1";
          };
        };
      }
      // lib'.mapListToAttrs (
        port:
        lib.nameValuePair "10-${port}" {
          matchConfig = {
            Name = port;
          };
          networkConfig = {
            Bridge = "lan";
            VLAN = "${port}.${toString nodes.current.interfaces.guest-lan.vlanId}";
          };
        }
      ) nodes.current.interfaces.lan.ports;
  };

  # Mac machines only accept the first IP from DHCPv6 which is not guaranteed to
  # be GUA
  # networking.wan.npt = [
  #   (node'.interfaces.lan.ipv6 { cidr = true; })
  #   (node'.interfaces.guest-lan.ipv6 { cidr = true; })
  # ];

  services.dnsmasq.settings = {
    dhcp-range =
      let
        inherit (nodes.current.dhcp.pool) start end;
      in
      [
        "${
          nodes.current.interfaces.lan.ipv4 {
            suffix = start;
            cidr = false;
          }
        },${
          nodes.current.interfaces.lan.ipv4 {
            suffix = end;
            cidr = false;
          }
        }"
        "::${toString start},::${toString end},constructor:lan,slaac,7d"
        "${
          nodes.current.interfaces.guest-lan.ipv4 {
            suffix = start;
            cidr = false;
          }
        },${
          nodes.current.interfaces.guest-lan.ipv4 {
            suffix = end;
            cidr = false;
          }
        }"
        "::${toString start},::${toString end},constructor:guest-lan,slaac,7d"
      ];
    dhcp-host =
      # reverse because dnsmasq take the last address when querying the
      # hostname, but we want to make it return the ip of the first device
      lib.reverseList (
        nodes.current.devices.concatMapInterfaces (
          dev: interface:
          lib.optional (interface ? ipSuffix)
            "${dev.name},${interface.macAddress},[::${toString interface.ipSuffix}],${
              interface.ipv4.lan { cidr = false; }
            }"
        )
      );
  };
  networking.nftables.tables.lan = {
    family = "inet";
    content = ''
      chain input {
        type filter hook input priority filter;
        iifname "guest-lan" jump input-guest-lan
      }
      chain input-guest-lan {
        ct state vmap { established : accept, related : accept }
        fib daddr type { broadcast, multicast } accept
        ip daddr != ${nodes.current.interfaces.guest-lan.ipv4 { cidr = false; }} drop
        ip6 daddr & ::ffff:ffff:ffff:ffff:ffff != 0:0:0:${toString nodes.current.interfaces.guest-lan.subnetId}::1 drop
        meta nfproto ipv4 udp sport 68 udp dport 67 accept comment "Allow DHCP"
        meta nfproto ipv6 udp sport 547 udp dport 546 accept comment "Allow DHCPv6"
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
        iifname "guest-lan" jump forward-guest-lan
      }
      chain forward-guest-lan {
        ct state vmap { established : accept, related : accept }
        oifname "wan" accept
        drop
      }
    '';
  };
}
