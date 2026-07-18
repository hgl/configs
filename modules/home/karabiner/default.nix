{ config, ... }:
let
  mkLink = config.lib.file.mkOutOfStoreSymlink;
  dir = "/Users/hgl/dev/configs/modules/home/karabiner";
in
{
  xdg.configFile."karabiner/assets/complex_modifications".source = mkLink dir;
}
