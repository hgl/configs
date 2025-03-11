{ pkgs, ... }:
{
  nixpkgs = {
    config.allowUnfree = true;
  };
  nix = {
    optimise.automatic = true;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
  programs.fish = {
    enable = true;
  };
  environment.shells = with pkgs; [
    fish
  ];

  users.users = {
    hgl = {
      description = "Glen Huang";
      shell = pkgs.fish;
    };
  };
}
