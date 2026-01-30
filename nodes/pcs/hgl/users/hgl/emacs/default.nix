{
  pkgs,
  config,
  ...
}:
let
  mkLink = config.lib.file.mkOutOfStoreSymlink;
  homeDir = "/Users/hgl/dev/configs/nodes/pcs/hgl/users/hgl";
in
{
  home.file.".config/emacs".source = mkLink "${homeDir}/emacs/emacs.d";

  home.packages = [
    pkgs.nerd-fonts.symbols-only
    ((pkgs.emacsPackagesFor pkgs.emacs-macport).withPackages (
      epkgs: with epkgs; [
        treesit-grammars.with-all-grammars
        (callPackage ./hel.nix { })
        vterm
        magit
        forge
        flymake
        org
        editorconfig
        envrc
        vertico
        orderless
        marginalia
        corfu
        consult
        nix-mode
        doom-themes
        doom-modeline
      ]
    ))
  ];
}
