{ pkgs, ... }:
let
  utmctl = pkgs.runCommand "utmctl" { } ''
    mkdir -p $out/bin
    ln -s /Applications/UTM.app/Contents/MacOS/utmctl $out/bin/utmctl
  '';
in
{
  environment.systemPackages = [
    utmctl
  ];
}
