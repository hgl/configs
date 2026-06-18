{
  outputs',
  pkgs,
  ...
}:
{
  default = pkgs.mkShellNoCC {
    name = "shell";
    packages = outputs'.devShellPackages;
  };
}
