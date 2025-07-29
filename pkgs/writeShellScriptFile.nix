{
  lib,
  runCommand,
  bash,
}:
path: packages:
let
  name = lib.removeSuffix ".sh" (baseNameOf path);
in
runCommand name
  {
    meta.mainProgram = name;
  }
  ''
    mkdir -p $out/bin
    substitute ${path} $out/bin/${name} \
    --subst-var-by shell ${lib.getExe bash} \
    --subst-var-by path ${lib.makeBinPath packages}
    chmod a=rx $out/bin/${name}
  ''
