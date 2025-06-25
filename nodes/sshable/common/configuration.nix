{
  lib,
  pkgs,
  nodes,
  ...
}:
let
  keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICezYVapRivfpiaxOFG09uty365vyGDqXSGfFKvB54yG hgl"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDrXT3k9ISbCa/VRCjQynAegfMQ5KhNIeh2WmC3C876u hgl-phone"
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
  [
    {
      users.users.${if lib.elem "pcs" nodes.current.parents then "hgl" else "root"} = {
        openssh.authorizedKeys.keys = keys;
      };
    }
  ]
  ++ lib.optional (lib.elem "servers" nodes.current.parents) {
    services.caddy.virtualHosts = {
      ${nodes.current.config.networking.fqdn}.extraConfig = ''
        handle_path /keys {
          file_server {
            root ${keysScript}
          }
        }
      '';
      ${nodes.current.config.networking.domain}.extraConfig = ''
        handle_path /keys {
          file_server {
            root ${keysScript}
          }
        }
      '';
    };
  }
  ++ lib.optional (lib.elem "routers" nodes.current.parents) {
    services.nginx.virtualHosts.${nodes.current.config.networking.fqdn}.locations."= /keys".alias =
      keysScript;
  }
)
