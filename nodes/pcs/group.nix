{
  hgl = {
    system = "aarch64-darwin";
    channel = "unstable";
  };
  hgl2 = {
    system = "x86_64-linux";
    channel = "unstable";
    install = {
      targetHost = "root@nixos";
    };
    deploy = {
      targetHost = "root@hgl2";
    };
  };
  glen = {
    system = "aarch64-darwin";
    channel = "unstable";
  };
}
