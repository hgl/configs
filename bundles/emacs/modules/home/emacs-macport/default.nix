{
  pkgs,
  config,
  pkgs',
  ...
}:
let
  mkLink = config.lib.file.mkOutOfStoreSymlink;
  dir = "/Users/hgl/dev/configs/bundles/emacs/modules/darwin/emacs-macport/emacs.d";
in
{
  home.packages = [
    pkgs'.emacs-macport
    pkgs.nerd-fonts.symbols-only
  ];
  home.file.".config/emacs".source = mkLink dir;
  home.shellAliases = {
    e = "emacsclient";
  };
}
