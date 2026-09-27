{
  laptop = {
    system = "aarch64-darwin";
    channel = "unstable";
  };
  laptop2 = {
    system = "x86_64-linux";
    channel = "unstable";
    install = {
      targetHost = "root@nixos";
    };
    deploy = {
      targetHost = "root@laptop2";
    };
  };
  pl-laptop = {
    system = "aarch64-darwin";
    channel = "unstable";
  };
}
