{
  imports = [
    ./emacs.nix
  ];
  nixpkgs = {
    hostPlatform = "aarch64-darwin";
  };
  nix = {
    # linux-builder = {
    #   enable = true;
    #   config = {
    #     # virtualisation.rosetta.enable = true;
    #     boot.binfmt.emulatedSystems = [ "x86_64-linux" ];
    #   };
    #   systems = [
    #     "x86_64-linux"
    #     "aarch64-linux"
    #   ];
    # };
    # settings.trusted-users = [ "hgl" ];
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "hgl-nixos.local";
        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];
      }
    ];
  };
  ids.gids.nixbld = 350;

  security.pam.services.sudo_local = {
    enable = true;
    touchIdAuth = true;
    reattach = true;
  };

  users.users = {
    hgl.home = "/Users/hgl";
    root.home = "/var/root";
  };

  networking = {
    computerName = "Glen’s Laptop";
  };
  system.defaults = {
    CustomUserPreferences = {
      "com.apple.menuextra.clock".ShowAMPM = 0;
      "com.apple.menuextra.clock".ShowDate = 2;
      "com.apple.menuextra.clock".ShowDayOfWeek = 0;
      "com.microsoft.VSCode".ApplePressAndHoldEnabled = false;
      "com.apple.finder".FXPreferredViewStyle = "nlsv";
      "com.apple.inputmethod.CoreChineseEngineFramework".shuangpinLayout = 4;
    };
  };

  system.stateVersion = 4;
}
