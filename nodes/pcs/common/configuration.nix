{ pkgs, inputs', ... }:
{
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };
  nixpkgs.overlays = [ inputs'.rust-overlay.overlays.default ];
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
