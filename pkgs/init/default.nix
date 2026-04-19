{
  writeShellApplication,
}:
writeShellApplication {
  name = "init";
  text = ''
    case ''${1-} in
    node)
      cp ${./.envrc} .envrc
      chmod +w .envrc
      cp ${./node.flake.nix} flake.nix
      chmod +w flake.nix
      direnv allow
      ;;
    python)
      cp ${./.envrc} .envrc
      chmod +w .envrc
      cp ${./python.flake.nix} flake.nix
      chmod +w flake.nix
      direnv allow
      ;;
    esac
  '';
}
