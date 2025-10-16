{ nodes, ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      ${nodes.vm-nixos.name} = {
        user = "root";
        hostname = "${nodes.vm-nixos.name}.local";
        identityFile = "~/.ssh/id_ed25519.pub";
        identitiesOnly = true;
      };
    };
  };
  home.file.".ssh/id_ed25519.pub".text =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMFTNE97QDW/v8PgMZoZz7kalVJUKVyI7eypqJuUrkos";

  home.stateVersion = "24.11";
}
