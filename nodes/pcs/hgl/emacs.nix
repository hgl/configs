{
  pkgs',
  pkgs,
  ...
}:
{
  system.activationScripts.applications.text = ''
    ${pkgs.mkalias}/bin/mkalias ${pkgs'.emacs}/Applications/Emacs.app /Applications/Emacs.app
  '';
}
