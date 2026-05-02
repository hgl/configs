{
  pkgs,
  inputs',
  ...
}:
{
  system.activationScripts.applications.text = ''
    ${pkgs.mkalias}/bin/mkalias ${inputs'.emacs.packages.emacs-macport}/Applications/Emacs.app /Applications/Emacs.app
  '';
}
