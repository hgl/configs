{
  lib,
  trivialBuild,
  fetchFromGitHub,
  runCommand,
  s,
  dash,
  avy,
  pcre2el,
  org,
  paredit,
}:
let
  src = fetchFromGitHub {
    owner = "anuvyklack";
    repo = "hel";
    rev = "e362a0d806759d87b2787ff76bdb8f6232010bf3";
    hash = "sha256-V9s1y8SJjU/wqMwRoPGvhuGBxybaOnXP0VmYMFL6C5M=";
  };
  buildExt =
    {
      name,
      packageRequires ? [ ],
      isDir ? false,
    }:
    trivialBuild {
      inherit name packageRequires;
      src = runCommand "${name}-src" { } ''
        mkdir $out
        cp ${src}/extensions/${name}.el $out
      '';
    };
  hel = trivialBuild {
    name = "hel";
    inherit src;
    packageRequires = [
      s
      dash
      avy
      pcre2el
    ];
    passthru = {
      extensions = {
        hel-leader = buildExt {
          name = "hel-leader";
          packageRequires = [
            s
            dash
            hel
          ];
        };
        hel-org = buildExt {
          name = "hel-org";
          packageRequires = [
            org
            hel
          ];
        };
        hel-paredit = buildExt {
          name = "hel-paredit";
          packageRequires = [
            paredit
            hel
          ];
        };
      };
    };
  };
in
hel
