{
  writeShellApplication,
}:
writeShellApplication {
  name = "init";
  text = ''
    case ''${1-} in
    node)
      cp ${./.envrc} .envrc
      cp ${./node.flake.nix} flake.nix
      direnv allow
      ;;
    esac
  '';
}
