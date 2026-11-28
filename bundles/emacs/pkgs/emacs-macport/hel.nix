{
  trivialBuild,
  fetchFromGitHub,
  dash,
  avy,
  pcre2el,
  ultra-scroll,
  org,
  paredit,
  vterm,
}:
let
  fetchHel =
    args:
    fetchFromGitHub (
      {
        owner = "anuvyklack";
      }
      // args
    );

  # Upstream moved every extension into a repository of its own (CHANGELOG:
  # "All extensions are moved to their own repositories"), so each one needs its
  # own pin. Before that they lived under extensions/<name>/ in the core
  # checkout and were carved out of it with runCommand; now each repo holds just
  # its own .el at the root, which trivialBuild can take directly.
  #
  # hel-leader also became its own repo, but nothing here used it, so it is no
  # longer exposed rather than carrying a fifth pin for it.
  extensions = {
    hel-org = {
      deps = [
        org
        dash
      ];
      src = fetchHel {
        repo = "hel-org";
        rev = "3d7dc4e4e05533f319a05da17d8defe36d6b35b7";
        hash = "sha256-73128sCRot/B//mqZ9gRJa25a57S+T/Wg2QQlYbtUOU=";
      };
    };
    hel-paredit = {
      deps = [
        paredit
        dash
      ];
      src = fetchHel {
        repo = "hel-paredit";
        rev = "0a00838256aef0b459a8f76a684b8e1dee755efc";
        hash = "sha256-CO+Yf+wT/Cym5I5WW24lIjhcva2r+6RAr2K+TeErqNk=";
      };
    };
    # hel-vterm declares no Package-Requires beyond emacs, but it exists to
    # drive vterm, so keep vterm on its load path.
    hel-vterm = {
      deps = [ vterm ];
      src = fetchHel {
        repo = "hel-vterm";
        rev = "733a5fa38d79cdddb0e9fc45cf784e541a35f14b";
        hash = "sha256-KaJRjzQtocv7j12rlWq4fUFSO5bdvWdnnlPApe7+zv4=";
      };
    };
  };

  buildExt =
    name: ext:
    trivialBuild {
      inherit name;
      inherit (ext) src;
      packageRequires = [ hel ] ++ ext.deps;
    };

  hel = trivialBuild {
    name = "hel";
    src = fetchHel {
      repo = "hel";
      rev = "68941b02448175b8da832054f34a515edc563ba0";
      hash = "sha256-exRKnjhdMjLFT8eyMeT+u4xTmoRHXyERNhcoRWX20bU=";
    };
    # Tracks the core's Package-Requires: it picked up ultra-scroll and no
    # longer needs s.
    packageRequires = [
      dash
      avy
      pcre2el
      ultra-scroll
    ];
    passthru.extensions = builtins.mapAttrs buildExt extensions;
  };
in
hel
