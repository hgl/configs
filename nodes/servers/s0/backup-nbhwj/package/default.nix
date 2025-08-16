{
  wordpressDir,
  cacheDir,
  dbName,
}:
{
  lib,
  runCommand,
  bash,
  mariadb,
  restic,
}:
let
  name = "backup-nbhwj";
in
runCommand name
  {
    meta.mainProgram = name;
  }
  ''
    mkdir -p $out/{bin,libexec}

    echo '#!@shell@' >$out/bin/${name}
    cat ${./entrypoint.sh} >>$out/bin/${name}
    substituteInPlace $out/bin/${name} \
      --subst-var-by shell ${lib.getExe bash} \
      --subst-var-by wordpressDir '${wordpressDir}' \
      --subst-var-by out $out

    echo '#!@shell@' >$out/libexec/backup
    echo 'export PATH=@path@' >>$out/libexec/backup
    cat ${./backup.sh} >>$out/libexec/backup
    substituteInPlace $out/libexec/backup \
      --subst-var-by shell ${lib.getExe bash} \
      --subst-var-by cacheDir '${cacheDir}' \
      --subst-var-by dbName '${dbName}' \
      --subst-var-by path ${
        lib.makeBinPath [
          mariadb
          restic
        ]
      }
    chmod a=rx $out/{bin/${name},libexec/backup}
  ''
