{
  config,
  pkgs,
  lib,
  lib',
  pkgs',
  ...
}:
let
  cfg = config.services.ipmon;
  rulesDir =
    rules:
    pkgs.linkFarm "ipmon-rules" (
      lib'.concatMapAttrsToList (name: rule: [
        {
          name = "${name}.json";
          path = pkgs.writeText "${name}.json" (builtins.toJSON { inherit (rule) interfaces watch; });
        }
        {
          inherit name;
          path = rule.script;
        }
      ]) rules
    );
in
{
  options =
    with lib;
    with types;
    {
      services.ipmon = {
        enable = mkEnableOption "network interface IP monitoring";
        rules = mkOption {
          type = attrsOf (submodule {
            options = {
              interfaces = mkOption {
                type = listOf str;
              };
              watch = mkOption {
                type = listOf str;
              };
              script = mkOption {
                type = path;
              };
            };
          });
        };
      };
    };
  config = {
    systemd.services.ipmon = {
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs'.ipmon}/bin/ipmon ${rulesDir cfg.rules}";
        Restart = "on-failure";
      };
    };
  };
}
