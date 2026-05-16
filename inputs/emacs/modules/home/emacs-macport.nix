{ pkgs, pkgs', ... }:
{
  home.packages = [
    pkgs'.emacs-macport
    pkgs.nerd-fonts.symbols-only
  ];
}
