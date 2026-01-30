{
  trivialBuild,
  fetchFromGitHub,
  s,
  dash,
  avy,
  pcre2el,
  paredit,
}:
trivialBuild {
  name = "hel";
  src = fetchFromGitHub {
    owner = "anuvyklack";
    repo = "hel";
    rev = "df736c007d07eb5a68e82f9fc25f3b4580f5aa47";
    hash = "sha256-LECZu4guC6bJ9b93NQNlHHlzc3BFmcP0JCGRPv1OMEM=";
  };
  packageRequires = [
    s
    dash
    avy
    pcre2el
    paredit
  ];
}
