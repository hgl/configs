{ inputs', ... }:
{
  imports = [ inputs'.virby.modules.virby ];

  services.virby = {
    enable = true;
    # debug = true;
    # rosetta = true;
  };
}
