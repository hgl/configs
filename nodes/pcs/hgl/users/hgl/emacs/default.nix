{
  pkgs,
  config,
  inputs',
  ...
}:
let
  mkLink = config.lib.file.mkOutOfStoreSymlink;
  homeDir = "/Users/hgl/dev/configs/nodes/pcs/hgl/users/hgl";
in
{
  home.file.".config/emacs".source = mkLink "${homeDir}/emacs/emacs.d";

  home.packages = [
    inputs'.emacs.packages.emacs-macport
    pkgs.nerd-fonts.symbols-only
  ];
}
