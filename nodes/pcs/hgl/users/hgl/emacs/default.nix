{
  pkgs,
  config,
  ...
}:
let
  mkLink = config.lib.file.mkOutOfStoreSymlink;
  homeDir = "/Users/hgl/dev/configs/nodes/pcs/hgl/users/hgl";
  emacs = (pkgs.emacsPackagesFor pkgs.emacs-macport).withPackages (
    epkgs:
    let
      hel = epkgs.callPackage ./hel.nix { };
      emacs-libgterm = epkgs.callPackage ./emacs-libgterm {
        emacs = pkgs.emacs-macport;
      };
      elisp-autofmt = epkgs.elisp-autofmt.overrideAttrs (
        finalAttrs: previousAttrs: {
          postInstall = ''
            substituteInPlace $out/share/emacs/site-lisp/elpa/$ename-$melpaVersion/elisp-autofmt.py \
              --replace-fail '#!/usr/bin/env python3' "#!${pkgs.python3}/bin/python3"
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
{
  home.file.".config/emacs".source = mkLink "${homeDir}/emacs/emacs.d";

  home.packages = [
    emacs
    pkgs.nerd-fonts.symbols-only
  ];
}
