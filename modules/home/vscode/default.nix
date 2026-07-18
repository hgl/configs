{ config, ... }:
let
  mkLink = config.lib.file.mkOutOfStoreSymlink;
  settingsFile = "/Users/hgl/dev/configs/modules/home/vscode/settings.json";
in
{
  home.file."Library/Application Support/Code/User/settings.json".source = mkLink settingsFile;
  home.sessionPath = [
    "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
  ];
}
