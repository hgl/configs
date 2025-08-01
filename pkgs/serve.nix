{
  writeShellApplication,
  static-web-server,
}:
writeShellApplication {
  name = "serve";
  runtimeInputs = [ static-web-server ];
  text = ''
    dir=''${1:-.}
    port=''${2:-8000}
    exec static-web-server --root "$dir" --port "$port" --directory-listing
  '';
}
