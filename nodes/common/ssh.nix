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
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBEiKGL8b89ObiPLa6+++d6fZCaTzhE+PITJ48/XTuzs vm-nixos"
  ];
  pwlessKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGJr3km3lHUk5EZFuEn9fDiVAx5B/vB4thNNdrUjm07W hgl";
  builderKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMFTNE97QDW/v8PgMZoZz7kalVJUKVyI7eypqJuUrkos root";

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
        openssh.authorizedKeys.keys = keys ++ [ pwlessKey ];
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
  ++ lib.optional (nodes.current.name == "vm-nixos") {
    users.users.root = {
      openssh.authorizedKeys.keys = [ builderKey ];
    };
  }
  ++ lib.optional (nodes.current.groups ? servers) {
    services.nginx.virtualHosts.host.locations."= /keys".alias = keysScript;
  }
  ++ lib.optional (nodes.current.name == "s0") {
    services.nginx.virtualHosts.main.locations."= /keys".alias = keysScript;
  }
  ++ lib.optional (nodes.current.groups ? routers) {
    services.nginx.virtualHosts.host.locations."= /keys".alias = keysScript;
  }
)
