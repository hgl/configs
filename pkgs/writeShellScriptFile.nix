{
  lib,
  runCommand,
  bash,
}:
name:
{ path, runtimeInputs }:
runCommand name
  {
    meta.mainProgram = name;
  }
  ''
    mkdir -p $out/bin
    echo '#!@shell@' >$out/bin/${name}
    echo 'export PATH=@path@' >>$out/bin/${name}
    cat ${path} >>$out/bin/${name}
    substituteInPlace $out/bin/${name} \
      --subst-var-by shell ${lib.getExe bash} \
      --subst-var-by path ${lib.makeBinPath runtimeInputs}
    chmod a=rx $out/bin/${name}
  ''
