{
  runCommand,
  emacs-macport,
}:
runCommand emacs-macport.name
  {
    emacs = emacs-macport;
    icon = ./liquid-glass-icon;
    preferLocalBuild = true;
    allowSubstitutes = false;
    inherit (emacs-macport) meta src;
  }
  ''
    mkdir -p $out/Applications/Emacs.app/Contents
    cp -r $emacs/bin $emacs/share $emacs/lib $out
    cp -r \
      $emacs/Applications/Emacs.app/Contents/MacOS \
      $emacs/Applications/Emacs.app/Contents/Info.plist \
      $emacs/Applications/Emacs.app/Contents/PkgInfo \
      $emacs/Applications/Emacs.app/Contents/Resources \
      $out/Applications/Emacs.app/Contents
    chmod +w $out/Applications/Emacs.app/Contents/Resources
    cp -f $icon/* $out/Applications/Emacs.app/Contents/Resources
  ''
