{ inputs', ... }:
{
  imports = [ inputs'.virby.modules.virby ];

  nix = {
    settings = {
      extra-substituters = [ "https://virby-nix-darwin.cachix.org" ];
      extra-trusted-public-keys = [
        "virby-nix-darwin.cachix.org-1:z9GiEZeBU5bEeoDQjyfHPMGPBaIQJOOvYOOjGMKIlLo="
      ];
    };
  };

  # nix.linux-builder.enable = true;
  services.virby = {
    # enable = true;
    # rosetta = true;
  };
}
