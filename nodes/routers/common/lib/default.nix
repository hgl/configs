{ lib, lib' }:
let
  addRouterInterfaceAttrs =
    router: interfaces:
    lib.imap0 (
      subnetId: interface:
      let
        ipv4Prefix = if router.subrouter then "192.168" else "10.${toString router.index}";
        ipv6Prefix = lib.elemAt (lib.match "([^/]+)::/.+" router.ulaPrefix) 0;
      in
      interface
      // {
        inherit subnetId;
        ipv6 =
          {
            suffix ? 1,
            cidr,
          }:
          "${ipv6Prefix}${lib.optionalString (subnetId != 0) ":${toString subnetId}"}::${
            lib.optionalString (suffix != 0) (toString suffix)
          }${lib.optionalString cidr "/64"}";
        ipv4 =
          {
            suffix ? 1,
            cidr,
          }:
          "${ipv4Prefix}.${toString subnetId}.${toString suffix}${lib.optionalString cidr "/24"}";
      }
      # subnetId starts at 0, but vlan id 0 is reserved, so make it starts at 1
      // lib.optionalAttrs (interface.vlan or false) {
        vlanId = subnetId + 1;
      }
    ) interfaces;
  hoistRouterInterfaces =
    interfaces:
    lib'.mapListToAttrs (
      interface: lib.nameValuePair interface.name (lib.removeAttrs interface [ "name" ])
    ) interfaces
    // {
      all = interfaces;
    };
  addDeviceInterfaceAttrs =
    router: devices:
    let
      addAttrs =
        deviceInterface: ipSuffix:
        deviceInterface
        // {
          ipv6 = lib'.mapListToAttrs (
            routerInterface:
            lib.nameValuePair routerInterface.name (
              { cidr }:
              routerInterface.ipv6 {
                suffix = ipSuffix;
                inherit cidr;
              }
            )
          ) router.interfaces.all;
          ipv4 = lib'.mapListToAttrs (
            routerInterface:
            lib.nameValuePair routerInterface.name (
              { cidr }:
              routerInterface.ipv4 {
                suffix = ipSuffix;
                inherit cidr;
              }
            )
          ) router.interfaces.all;
        };
    in
    map (
      dev:
      if dev ? ipSuffix then
        if dev ? interfaces then
          lib.removeAttrs dev [ "ipSuffix" ]
          // {
            interfaces = lib.imap0 (
              i: interface:
              let
                ipSuffix = dev.ipSuffix + i;
              in
              addAttrs interface ipSuffix // { inherit ipSuffix; }
            ) dev.interfaces;
          }
        else
          addAttrs dev dev.ipSuffix
      else
        dev
    ) devices;
  hoistDeviceInterfaces =
    devices:
    map (
      dev:
      dev
      // lib.optionalAttrs (dev ? interfaces) {
        interfaces =
          lib'.mapListToAttrs (
            interface: lib.nameValuePair interface.name (lib.removeAttrs interface [ "name" ])
          ) dev.interfaces
          // {
            all = dev.interfaces;
          };
      }
    ) devices;
  hoistDevices =
    devices:
    lib'.mapListToAttrs (dev: lib.nameValuePair dev.name (lib.removeAttrs dev [ "name" ])) devices
    // {
      all = devices;
      concatMapInterfaces =
        f:
        lib.concatMap (
          dev:
          if dev ? interfaces then
            lib.concatMap (interface: f dev interface) dev.interfaces.all
          else
            f dev dev
        ) devices;
    };
in
{
  interfaces =
    router: interfaces:
    lib.pipe interfaces [
      (addRouterInterfaceAttrs router)
      hoistRouterInterfaces
    ];
  devices =
    router: devices:
    lib.pipe devices [
      (addDeviceInterfaceAttrs router)
      hoistDeviceInterfaces
      hoistDevices
    ];
}
