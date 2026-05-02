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
  vterm,
}:
let
  src = fetchFromGitHub {
    owner = "anuvyklack";
    repo = "hel";
    rev = "489f48a1bb8b41a8b681821ecbfc4a7cb33fc5c0";
    hash = "sha256-n/aplUWdlAI0kyEhif3oikaAILFQDoRM+ohEqvHKBIs=";
  };
  buildExt =
    name: deps:
    trivialBuild {
      inherit name;
      packageRequires = [ hel ] ++ deps;
      src = runCommand "${name}-src" { } ''
        mkdir $out
        cp ${src}/extensions/${name}/*.el $out
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
        hel-leader = buildExt "hel-leader" [
          s
          dash
        ];
        hel-org = buildExt "hel-org" [
          org
        ];
        hel-paredit = buildExt "hel-paredit" [
          paredit
        ];
        hel-vterm = buildExt "hel-vterm" [
          vterm
        ];
      };
    };
  };
in
hel
