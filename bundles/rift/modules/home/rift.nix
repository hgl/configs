{
  lib,
  pkgs,
  config,
  pkgs',
  ...
}:
let
  cfg = config.services.rift;
  format = pkgs.formats.toml { };
  settingsFile = format.generate "config.toml" cfg.settings;
in
{
  options.services.rift = {
    enable = lib.mkEnableOption "Rift - A tiling window manager for macOS";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs'.rift;
      description = "The rift package to use.";
    };

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Rift settings configuration.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [ (lib.hm.assertions.assertPlatform "services.paneru" pkgs lib.platforms.darwin) ];
    home.packages = [ cfg.package ];

    xdg.configFile."rift/config.toml".source = settingsFile;

    launchd.agents.rift = {
      enable = true;
      config = {
        Label = "com.github.acsandmann.rift";
        Program = lib.getExe cfg.package;
        RunAtLoad = true;
        KeepAlive = {
          Crashed = true;
          SuccessfulExit = false;
        };
        StandardOutPath = "/tmp/rift.log";
        StandardErrorPath = "/tmp/rift.log";
      };
    };
  };
}
