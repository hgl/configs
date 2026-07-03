{ pkgs, ... }:
{
  home.packages = [
    pkgs.nodejs_26
    pkgs.pnpm
    pkgs.yarn
  ];

  home.file.".npmrc".text = ''
    prefix=~/.npm
  '';
}
