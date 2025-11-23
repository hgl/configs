{ pkgs, ... }:
{
  home.packages = [
    pkgs.nodejs_24
    pkgs.pnpm
    pkgs.yarn
  ];

  home.file.".npmrc".text = ''
    prefix=~/.npm
  '';
}
