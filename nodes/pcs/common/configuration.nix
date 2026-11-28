{ pkgs, nodes, ... }:
{
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };
  nixpkgs = {
    config.allowUnfree = true;
  };
  users.users = {
    ${nodes.current.users.main.name} = {
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
