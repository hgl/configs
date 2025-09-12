{
  lib,
  lib',
  pkgs,
  nodes,
  ...
}:
let
  keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICezYVapRivfpiaxOFG09uty365vyGDqXSGfFKvB54yG hgl"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDrXT3k9ISbCa/VRCjQynAegfMQ5KhNIeh2WmC3C876u hgl-phone"
  ];
  builderKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMFTNE97QDW/v8PgMZoZz7kalVJUKVyI7eypqJuUrkos root"
  ];
  # Make nixos installer accept ssh keys by running
  # curl -L <domain> | sudo sh
  keysScript = pkgs.writeText "keys" ''
    mkdir -p /root/.ssh
    cat <<EOF >/root/.ssh/authorized_keys
    ${lib.concatStringsSep "\n" keys}
    EOF
  '';
in
lib.mkMerge (
  lib.optional
    (lib'.hasAnyAttr [ "servers" "routers" "vms" ] nodes.current.groups && nodes.current.os == "nixos")
    {
      users.users.root = {
        openssh.authorizedKeys.keys = keys ++ lib.optionals (nodes.current.groups ? vms) builderKeys;
      };

      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
        };
      };
    }
  ++ lib.optional (nodes.current.name == "vm-nixos") {
    users.users.root = {
      # For using it as a nixos remote builder
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMFTNE97QDW/v8PgMZoZz7kalVJUKVyI7eypqJuUrkos"
      ];
    };
  }
  ++ lib.optional (nodes.current.groups ? servers) {
    services.nginx.virtualHosts = {
      host.extraConfig = ''
        location /keys {
          try_files ${keysScript} =404;
        }
      '';
      main.extraConfig = ''
        location /keys {
          try_files ${keysScript} =404;
        }
      '';
    };
  }
  ++ lib.optional (nodes.current.groups ? routers) {
    services.nginx.virtualHosts.host.locations."= /keys".alias = keysScript;
  }
)
