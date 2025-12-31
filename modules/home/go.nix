{ config, ... }:
{
  programs.go = {
    enable = true;
    env.GOPATH = "${config.home.homeDirectory}/Library/go";
    telemetry.mode = "off";
  };
}
