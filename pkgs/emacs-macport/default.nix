{
  emacs-macport,
}:
let
  emacs = emacs-macport.overrideAttrs (
    finalAttrs: previousAttrs: {
      postInstall = previousAttrs.postInstall + ''
        cp ${./savchenkovaleriy-big-sur.icns} $out/Applications/Emacs.app/Contents/Resources/Emacs.icns
      '';
    }
  );
in
emacs.pkgs.withPackages (epkgs: [ epkgs.vterm ])
