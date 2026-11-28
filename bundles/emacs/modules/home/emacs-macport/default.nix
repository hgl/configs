{
  pkgs,
  pkgs',
  ...
}:
{
  home.packages = [
    pkgs'.emacs-macport
    pkgs.nerd-fonts.symbols-only
  ];
  # Linked file by file rather than as a single directory symlink, so
  # ~/.config/emacs stays a writable directory. early-init.el and init.el
  # redirect the eln cache, auto-saves and savehist into the XDG cache, but
  # emacs still writes transient/, projects, recentf and bookmarks into
  # user-emacs-directory, which a read-only store path would break.
  home.file.".config/emacs" = {
    source = ./emacs.d;
    recursive = true;
  };
  home.shellAliases = {
    e = "emacsclient";
  };
}
