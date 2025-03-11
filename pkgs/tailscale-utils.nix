{
  buildGo123Module,
  fetchFromGitHub,
}:
let
  version = "1.76.6";
in
buildGo123Module {
  pname = "tailscale-util";
  inherit version;
  src = fetchFromGitHub {
    owner = "tailscale";
    repo = "tailscale";
    rev = "v${version}";
    hash = "sha256-c44Fz/cYGN2nsjlaKln8ozjjS5jHSO/X9RMnHa37tJM=";
  };
  ldflags = [
    "-w"
    "-s"
    "-X tailscale.com/version.longStamp=${version}"
    "-X tailscale.com/version.shortStamp=${version}"
  ];
  vendorHash = "sha256-xCZ6YMJ0fqVzO+tKbCzF0ftV05NOB+lJbJBovLqlrtQ=";
  doCheck = false;
  subPackages = [ "cmd/get-authkey" ];
  postInstall = ''
    find $out/bin \
      -mindepth 1 \
      -maxdepth 1 \
      -executable |
      while read -r f; do
        name=$(basename "$f")
        dir=$(dirname "$f")
        mv "$f" "$dir/tailscale-$name"
      done
  '';
}
