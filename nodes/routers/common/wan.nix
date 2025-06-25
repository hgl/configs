{
  config,
  pkgs,
  lib,
  nodes,
  ...
}:
let
  wan = lib.elemAt nodes.current.wan.ports 0;
  wanType = if nodes.current.subrouter then "dhcp" else wan.type;
  portOrPortRange =
    with lib.types;
    oneOf [
      port
      (submodule {
        options = {
          from = mkOption {
            type = port;
          };
          to = mkOption {
            type = port;
          };
        };
      })
    ];
  cfg = config.networking.wan;
  portStr =
    port: if lib.isAttrs port then "${toString port.start}-${toString port.end}" else toString port;
  portsStr = ports: "{ ${lib.concatMapStringsSep "," portStr ports} }";
  setStr = els: "{ ${lib.concatStringsSep "," els} }";
  quotedSetStr = els: "{ ${lib.concatMapStringsSep "," (el: "\"${el}\"") els} }";
  ipVer = ip: lib.optionalString (lib.hasInfix ":" ip) "6";
  allowedInput = map (
    r:
    "${
      lib.optionalString (r.source.ips == [ ] && !(r.ipv6 && r.ipv4))
        "meta nfproto ${if r.ipv6 then "ipv6" else "ipv4"}"
    } ${
      lib.optionalString (
        r.source.ips != [ ]
      ) "ip${ipVer (lib.elemAt r.source.ips 0)} saddr ${setStr r.source.ips}"
    } ${"meta l4proto ${setStr r.protocols}"} ${
      lib.optionalString (r.source.ports != [ ]) "th sport ${portsStr r.source.ports}"
    } ${
      lib.optionalString (r.destination.ports != [ ]) "th dport ${portsStr r.destination.ports}"
    } accept"
  ) (lib.filter (r: r.destination.ips == [ ] && r.destination.ifanmes == [ ]) cfg.allowedTraffics);
  # TODO: dstIps can be a list or an attrs, not a good design
  forwardStr =
    r: dstIps:
    "${
      lib.optionalString (
        r.source.ips == [ ] && r.destination.ips == [ ] && !(r.ipv6 && r.ipv4)
      ) "meta nfproto ${if r.ipv6 then "ipv6" else "ipv4"}"
    } ${
      lib.optionalString (
        r.source.ips != [ ]
      ) "ip${ipVer (lib.elemAt r.source.ips 0)} saddr ${setStr r.source.ips}"
    } ${"meta l4proto ${setStr r.protocols}"} ${
      lib.optionalString (r.source.ports != [ ]) "th sport ${portsStr r.source.ports}"
    } ${lib.optionalString (r.destination.ports != [ ]) "th dport ${portsStr r.destination.ports}"} ${
      lib.optionalString (
        lib.isList dstIps && dstIps != [ ]
      ) "ip${ipVer (lib.elemAt dstIps 0)} daddr ${setStr dstIps}"
    } ${lib.optionalString (lib.isAttrs dstIps) "ip6 daddr & ${dstIps.mask} == ${dstIps.addr}"} ${
      lib.optionalString (r.destination.ifanmes != [ ]) "oifname ${quotedSetStr r.destination.ifanmes}"
    } accept";
  forwardRules = lib.concatMap (
    r:
    if r.destination.ips == [ ] && r.destination.ifanmes == [ ] then
      [ ]
    else
      [
        (builtins.foldl'
          (
            attrs: ip:
            let
              parts = lib.split "/" ip;
            in
            if lib.length parts == 3 && lib.hasInfix ":" (lib.elemAt parts 2) then
              attrs
              // {
                maskedDstIps = attrs.maskedDstIps ++ [
                  {
                    addr = lib.elemAt parts 0;
                    mask = "${lib.elemAt parts 2}";
                  }
                ];
              }
            else
              attrs // { regularDstIps = attrs.regularDstIps ++ [ ip ]; }
          )
          {
            rule = r;
            regularDstIps = [ ];
            maskedDstIps = [ ];
          }
          r.destination.ips
        )
      ]
  ) cfg.allowedTraffics;
  allowedForward = lib.concatMap (
    {
      rule,
      regularDstIps,
      maskedDstIps,
    }:
    lib.optional (rule.destination.ifanmes != [ ] || regularDstIps != [ ]) (
      forwardStr rule regularDstIps
    )
    ++ map (ip: forwardStr rule ip) (maskedDstIps)
  ) forwardRules;
  allowedDstnat = map (
    r:
    "${
      lib.optionalString (
        r.source.ip == "" && r.destination.ip == "" && !(r.ipv6 && r.ipv4)
      ) "meta nfproto ${if r.ipv6 then "ipv6" else "ipv4"}"
    } ${lib.optionalString (r.source.ip != "") "ip saddr ${r.source.ip} "} ${
      if r.tcp && r.udp then
        "meta l4proto { tcp, udp } th"
      else if r.tcp then
        "tcp"
      else
        "udp"
    } ${
      lib.optionalString (r.source.port != null) "sport ${portStr r.source.port}"
    } dport ${toString r.destination.externalPort} ${
      let
        port =
          if r.destination.internalPort == null then
            r.destination.externalPort
          else
            r.destination.internalPort;
      in
      if r.destination.ip == "" then
        "redirect to :${toString port}"
      else
        "dnat ip${ipVer r.destination.ip} to ${r.destination.ip}:${toString port}"
    }"
  ) cfg.portForwards;
in
{
  options =
    with lib;
    with types;
    {
      networking.wan = {
        allowedTraffics = mkOption {
          type = listOf (submodule {
            options = {
              ipv6 = mkOption {
                type = bool;
                default = true;
              };
              ipv4 = mkOption {
                type = bool;
                default = true;
              };
              protocols = mkOption {
                type = listOf (enum [
                  "icmp"
                  "igmp"
                  "ggp"
                  "ipencap"
                  "st"
                  "tcp"
                  "egp"
                  "pup"
                  "udp"
                  "hmp"
                  "xns-idp"
                  "rdp"
                  "iso-tp4"
                  "xtp"
                  "ddp"
                  "idpr-cmtp"
                  "ipv6"
                  "ipv6-route"
                  "ipv6-frag"
                  "idrp"
                  "rsvp"
                  "gre"
                  "esp"
                  "ah"
                  "skip"
                  "ipv6-icmp"
                  "ipv6-nonxt"
                  "ipv6-opts"
                  "rspf"
                  "vmtp"
                  "ospf"
                  "ipip"
                  "encap"
                  "pim"
                ]);
                default = [
                  "tcp"
                  "udp"
                ];
              };
              source = {
                ips = mkOption {
                  type = listOf nonEmptyStr;
                  default = [ ];
                };
                ports = mkOption {
                  type = listOf portOrPortRange;
                  default = [ ];
                };
              };
              destination = {
                ifanmes = mkOption {
                  type = listOf nonEmptyStr;
                  default = [ ];
                };
                ips = mkOption {
                  type = listOf nonEmptyStr;
                  default = [ ];
                };
                ports = mkOption {
                  type = listOf portOrPortRange;
                  default = [ ];
                };
              };
            };
          });
          default = [ ];
        };
        portForwards = mkOption {
          type = listOf (submodule {
            options = {
              ipv6 = mkOption {
                type = bool;
                default = true;
              };
              ipv4 = mkOption {
                type = bool;
                default = true;
              };
              udp = mkOption {
                type = bool;
                default = true;
              };
              tcp = mkOption {
                type = bool;
                default = true;
              };
              source = {
                ip = mkOption {
                  type = str;
                  default = "";
                };
                port = mkOption {
                  type = nullOr portOrPortRange;
                  default = null;
                };
              };
              destination = {
                ip = mkOption {
                  type = str;
                  default = "";
                };
                externalPort = mkOption {
                  type = port;
                };
                internalPort = mkOption {
                  type = nullOr port;
                  default = null;
                };
              };
            };
          });
          default = [ ];
        };
        npt = mkOption {
          type = listOf nonEmptyStr;
          default = [ ];
        };
      };
    };
  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = lib.all (r: r.ipv6 || r.ipv4) cfg.allowedTraffics;
          message = "ipv6 and ipv4 cannot both be false in networking.wan.allowedTraffics";
        }
        {
          assertion = lib.all (r: r.ipv6 || r.ipv4) cfg.portForwards;
          message = "ipv6 and ipv4 cannot both be false in networking.wan.portForwards";
        }
        {
          assertion = lib.all (
            r:
            r.source.ports == [ ] && r.destination.ports == [ ]
            ||
              (lib.subtractLists [
                "tcp"
                "udp"
              ] r.protocols) == [ ]
          ) cfg.allowedTraffics;
          message = "only tcp and udp support ports in networking.wan.allowedTraffics";
        }
        {
          assertion = lib.all (r: r.tcp || r.udp) cfg.portForwards;
          message = "tcp and udp cannot both be false in networking.wan.portForwards";
        }
        {
          assertion = lib.all (
            r: !(r.destination.ip == "" && r.destination.internalPort == null)
          ) cfg.portForwards;
          message = "either destination.ip or destination.internalPort must be specified in networking.wan.portForwards";
        }
      ];

      networking.wan = {
        portForwards = nodes.current.devices.concatMapInterfaces (
          dev: interface:
          if dev ? openedPorts then
            lib.concatMap (ports: [
              {
                udp = ports.udp or true;
                tcp = ports.tcp or true;
                destination = {
                  ip = interface.ipv4.lan { cidr = false; };
                  inherit (ports) externalPort;
                  internalPort = ports.internalPort or null;
                };
              }
            ]) dev.openedPorts
          else
            [ ]
        );
        allowedTraffics =
          nodes.current.devices.concatMapInterfaces (
            dev: interface:
            if dev ? openedPorts then
              lib.concatMap (ports: [
                {
                  protocols = lib.optional (ports.tcp or true) "tcp" ++ lib.optional (ports.udp or true) "udp";
                  destination = {
                    ips = [ "::${toString interface.ipSuffix}/::ffff" ];
                    ports = [ (if ports.internalPort or null == null then ports.externalPort else ports.internalPort) ];
                  };
                }
              ]) dev.openedPorts
            else
              [ ]
          )
          ++ [
            # ssh
            {
              protocols = [ "tcp" ];
              destination.ports = [
                22
              ];
            }
          ];
      };

      networking.nftables.tables.wan = {
        family = "inet";
        content = ''
          chain input {
            type filter hook input priority filter;
            iifname "wan" jump input-wan
          }
          chain input-wan {
            ct state vmap { established : accept, related : accept }
            meta nfproto ipv4 udp sport 67 udp dport 68 accept comment "Allow DHCP"
            meta nfproto ipv6 udp sport 547 udp dport 546 accept comment "Allow DHCPv6"
            icmp type echo-request accept comment "Allow Ping"
            meta nfproto ipv4 meta l4proto igmp accept comment "Allow IGMP"
            ip6 saddr fe80::/10 icmpv6 type . icmpv6 code { mld-listener-query . no-route, mld-listener-report . no-route, mld-listener-done . no-route, mld2-listener-report . no-route } accept comment "Allow MLD"
            icmpv6 type { destination-unreachable, time-exceeded, echo-request, echo-reply, nd-router-solicit, nd-router-advert } limit rate 1000/second burst 5 packets accept comment "Allow ICMPv6-Input"
            icmpv6 type . icmpv6 code { packet-too-big . no-route, parameter-problem . no-route, nd-neighbor-solicit . no-route, nd-neighbor-advert . no-route, parameter-problem . admin-prohibited } limit rate 1000/second burst 5 packets accept comment "Allow ICMPv6 Input"
            ${lib.concatLines allowedInput}
            ct status dnat accept
            drop
          }

          chain forward {
            type filter hook forward priority filter;
            iifname "wan" jump forward-wan
          }
          chain forward-wan {
            ct state vmap { established : accept, related : accept }
            icmpv6 type { destination-unreachable, time-exceeded, echo-request, echo-reply } limit rate 1000/second burst 5 packets accept comment "Allow ICMPv6 Forward"
            icmpv6 type . icmpv6 code { packet-too-big . no-route, parameter-problem . no-route, parameter-problem . admin-prohibited } limit rate 1000/second burst 5 packets accept comment "Allow ICMPv6 Forward"
            ${lib.concatLines allowedForward}
            ct status dnat accept
            drop
          }

          chain srcnat {
            type nat hook postrouting priority srcnat;
            snat ip6 prefix to ip6 saddr map @npt
            oifname "wan" meta nfproto ipv4 masquerade
          }

          chain dstnat {
            type nat hook prerouting priority dstnat;
            iifname "wan" jump dstnat-wan
          }
          chain dstnat-wan {
            ${lib.concatLines allowedDstnat}
          }

          map npt {
            type ipv6_addr : interval ipv6_addr
            flags interval
          }
        '';
      };

      services.networkd-ipmon = lib.mkIf (config.networking.wan.npt != [ ]) {
        enable = true;
        rules.wan-npt = {
          interfaces = [ "wan" ];
          properties = [ "PD_ADDRS" ];
          script = pkgs.writeShellScript "wan-npt" ''
            set -e
            ${lib.getExe pkgs.nftables} flush map inet wan npt
            first() {
              echo "$1"
            }
            if [[ -n $PD_ADDRS ]]; then
              addr=$(first $PD_ADDRS)
              ${lib.getExe pkgs.nftables} add element inet wan npt \{ ${
                lib.concatStringsSep "," (map (prefix: "${prefix} : $addr") config.networking.wan.npt)
              } }
            fi
          '';
        };
      };
    }
    (lib.mkIf (wanType == "pppoe") {
      systemd.network.networks = {
        # This is required to bring the wan interface up
        "20-wan-link" = {
          matchConfig = {
            Name = wan.name;
          };
          networkConfig = {
            LinkLocalAddressing = false;
          };
        };
        "20-wan" = {
          matchConfig = {
            Name = "wan";
          };
          networkConfig = {
            IPv6LinkLocalAddressGenerationMode = "stable-privacy";
            DHCP = "ipv6";
            IPv6AcceptRA = true;
            IPv6SendRA = false;
          };
          dhcpV6Config = {
            PrefixDelegationHint = "::/56";
            SendHostname = false;
            WithoutRA = "solicit";
          };
          dhcpPrefixDelegationConfig = {
            UplinkInterface = ":self";
          };
          ipv6AcceptRAConfig = {
            DHCPv6Client = "always";
          };
        };
      };
      services.pppd = {
        enable = wanType == "pppoe";
        peers.wan.config = ''
          plugin pppoe.so
          nic-${wan.name}
          +ipv6
          nodetach
          ifname wan
          usepeerdns
          defaultroute
          persist
          maxfail 0
          lcp-echo-interval 1
          lcp-echo-failure 5
          lcp-echo-adaptive
          up_sdnotify
          name ${wan.pppoeUsername}
        '';
      };
      systemd.services.pppd-wan.serviceConfig.Type = "notify";

      sops.secrets.wanPppoePassword = { };
      environment.etc."ppp/pap-secrets" = {
        mode = "0600";
        text = ''
          ${wan.pppoeUsername} * @${config.sops.secrets.wanPppoePassword.path} *
        '';
      };
    })
    (lib.mkIf (wanType == "dhcp") {
      systemd.network = {
        links."20-wan" = {
          matchConfig = {
            # can't use OriginalName here because it sometimes doesn't work
            # https://github.com/systemd/systemd/issues/24975#issuecomment-1276669267
            PermanentMACAddress = wan.macAddress;
          };
          linkConfig = {
            Name = "wan";
          };
        };
        networks."20-wan" = {
          matchConfig = {
            Name = "wan";
          };
          networkConfig = {
            IPv6LinkLocalAddressGenerationMode = "stable-privacy";
            DHCP = "yes";
          };
        };
      };
    })
  ];
}
