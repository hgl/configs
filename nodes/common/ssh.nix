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
    (lib.elem nodes.current.name [
      "vm-nixos"
      "hgl"
      "hgl2"
    ])
    {
      users.users.hgl = {
        openssh.authorizedKeys.keys = keys;
      };
    }
  ++ lib.optional (nodes.current.os == "nixos") {
    users.users.root = {
      openssh.authorizedKeys.keys = keys;
    };

    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };
  }
  ++ lib.optional (nodes.current.os == "darwin") {
    users.users.root = {
      openssh.authorizedKeys.keys = keys;
    };

    services.openssh = {
      enable = true;
      extraConfig = ''
        PasswordAuthentication no
        KbdInteractiveAuthentication no
      '';
    };
  }
  ++ lib.optional (nodes.current.name == "vm-nixos-builder") {
    users.users.root = {
      openssh.authorizedKeys.keys = builderKeys;
    };
  }
  ++ lib.optional (nodes.current.groups ? servers) {
    services.nginx.virtualHosts = {
      host.locations."= /keys".alias = keysScript;
      main.locations."= /keys".alias = keysScript;
    };
  }
  ++ lib.optional (nodes.current.groups ? routers) {
    services.nginx.virtualHosts.host.locations."= /keys".alias = keysScript;
  }
)
