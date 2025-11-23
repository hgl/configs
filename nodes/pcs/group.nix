{
  hgl = {
    os = "darwin";
    channel = "unstable";
  };
  hgl2 = {
    os = "nixos";
    channel = "unstable";
    install = {
      targetHost = "root@nixos";
    };
    deploy = {
      targetHost = "root@hgl2";
    };
  };
}
