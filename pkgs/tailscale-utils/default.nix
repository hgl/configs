{
  buildGoModule,
}:
buildGoModule {
  name = "tailscale-util";
  src = ./.;
  vendorHash = "sha256-ot9UVTcEZdQ/c8VfPkGIje5fA/fCBdo81dMKk8aKotw=";
  subPackages = [ "authkey" ];
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
