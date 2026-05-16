{
  lib,
  emacsPackagesFor,
  emacs-macport,
  python3,
}:
let
  emacs = emacs-macport.overrideAttrs (
    finalAttrs: previousAttrs: {
      postInstall = (previousAttrs.postInstall or "") + ''
        cp -f ${./liquid-glass-icon}/* $out/Applications/Emacs.app/Contents/Resources
      '';
    }
  );
  emacsWithPackages = (emacsPackagesFor emacs).withPackages (
    epkgs:
    let
      hel = epkgs.callPackage ./hel.nix { };
      emacs-libgterm = epkgs.callPackage ./emacs-libgterm {
        inherit emacs;
      };
      elisp-autofmt = epkgs.elisp-autofmt.overrideAttrs (
        finalAttrs: previousAttrs: {
          postInstall = ''
            substituteInPlace $out/share/emacs/site-lisp/elpa/$ename-$melpaVersion/elisp-autofmt.py \
              --replace-fail '#!/usr/bin/env python3' "#!${python3}/bin/python3"
          '';
        }
      );
    in
    with epkgs;
    [
      hel
      hel.extensions.hel-org
      hel.extensions.hel-paredit
      hel.extensions.hel-vterm
      treesit-grammars.with-all-grammars
      vterm
      magit
      forge
      flymake
      editorconfig
      org-roam
      envrc
      vertico
      orderless
      marginalia
      corfu
      consult
      nix-mode
      doom-themes
      doom-modeline
      elisp-autofmt
      emacs-libgterm
    ]
  );
in
emacsWithPackages.overrideAttrs (
  finalAttrs: previousAttrs: {
    meta = (previousAttrs.meta or { }) // {
      description = "GNU Emacs Mac port with bundled Emacs packages";
      homepage = "https://bitbucket.org/mituharu/emacs-mac";
      license = lib.licenses.gpl3Plus;
      mainProgram = "emacs";
      platforms = lib.platforms.darwin;
    };
  }
)
