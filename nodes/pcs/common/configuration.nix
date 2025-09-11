{ pkgs, ... }:
{
  nixpkgs = {
    config.allowUnfree = true;
  };

  users.users = {
    hgl = {
      description = "Glen Huang";
      shell = pkgs.fish;
    };
  };
  programs.fish = {
    enable = true;
  };
  environment.shells = [
    pkgs.fish
  ];
}
