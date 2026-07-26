{pkgs, ...}: {
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      extra-substituters = [ "https://hgl.cachix.org" ];
      extra-trusted-public-keys = [ "hgl.cachix.org-1:niFEnN9pxxWAvFsgbxCw9YaCdEfrDUV8wgWfS1HpK0M=" ];
    };
  };

  environment.systemPackages = with pkgs; [
    git
  ];

  system.stateVersion = 6;
}
