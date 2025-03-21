{
  emacs,
  emacsPackagesFor,
}:
let
  emacsWithIcon = emacs.overrideAttrs (
    finalAttrs: previousAttrs: {
      postInstall =
        previousAttrs.postInstall
        + ''
          cp ${./savchenkovaleriy-big-sur.icns} $out/Applications/Emacs.app/Contents/Resources/Emacs.icns
        '';
    }
  );
in
(emacsPackagesFor emacsWithIcon).emacsWithPackages (epkgs: [ epkgs.vterm ])
