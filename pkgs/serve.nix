{
  writeShellApplication,
  caddy,
}:
writeShellApplication {
  name = "serve";
  runtimeInputs = [ caddy ];
  text = ''
    dir=''${1:-.}
    port=''${2:-8000}
    exec caddy file-server --browse --root "$dir" --listen ":$port"
  '';
}
