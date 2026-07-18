{ config, ... }:
let
  mkLink = config.lib.file.mkOutOfStoreSymlink;
  keysFile = "/Users/hgl/dev/configs/modules/home/sopsAgeKeys/keys.txt";
in
{
  xdg.configFile."sops/age/keys.txt".source = mkLink keysFile;
}
