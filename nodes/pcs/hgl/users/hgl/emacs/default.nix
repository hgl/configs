{
  config,
  modules',
  ...
}:
let
  mkLink = config.lib.file.mkOutOfStoreSymlink;
  homeDir = "/Users/hgl/dev/configs/nodes/pcs/hgl/users/hgl";
in
{
  imports = [
    modules'.emacs-macport
  ];
  home.file.".config/emacs".source = mkLink "${homeDir}/emacs/emacs.d";
}
