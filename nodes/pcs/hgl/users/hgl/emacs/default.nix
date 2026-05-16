{
  config,
  inputs',
  ...
}:
let
  mkLink = config.lib.file.mkOutOfStoreSymlink;
  homeDir = "/Users/hgl/dev/configs/nodes/pcs/hgl/users/hgl";
in
{
  imports = [
    inputs'.emacs.modules.emacs-macport
  ];
  home.file.".config/emacs".source = mkLink "${homeDir}/emacs/emacs.d";
}
