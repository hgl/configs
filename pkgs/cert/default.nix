{
  lib,
  bash,
  runCommand,
  util-linux,
  openssl,
  cfssl,
  jq,
}:
runCommand "cert"
  {
    meta.mainProgram = "cert";
  }
  ''
    mkdir -p $out/bin
    substitute ${./cert.sh} $out/bin/cert \
    --subst-var-by shell ${lib.getExe bash} \
    --subst-var-by out $out \
    --subst-var-by path ${
      lib.makeBinPath [
        util-linux
        openssl
        cfssl
        jq
      ]
    }
    chmod a=rx $out/bin/cert
  ''
