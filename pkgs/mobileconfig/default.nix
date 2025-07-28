{
  lib,
  bash,
  runCommand,
  coreutils,
  util-linux,
  openssl,
  yq,
  gnused,
  nixverse,
  pkgs',
}:
runCommand "mobileconfig"
  {
    meta.mainProgram = "mobileconfig";
  }
  ''
    mkdir -p $out/bin
    substitute ${./mobileconfig.sh} $out/bin/mobileconfig \
    --subst-var-by shell ${lib.getExe bash} \
    --subst-var-by out $out \
    --subst-var-by path ${
      lib.makeBinPath [
        coreutils
        util-linux
        openssl
        yq
        gnused
        nixverse
        pkgs'.cert
      ]
    }
    chmod a=rx $out/bin/mobileconfig
  ''
