{ config, ... }:
{
  programs.go = {
    enable = true;
    env.GOPATH = "${config.home.homeDirectory}/Library/go";
  };
  home.sessionPath = [
    "$GOPATH/bin"
  ];
}
