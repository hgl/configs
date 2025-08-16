{
  pkgs,
  config,
  nodes,
  ...
}:
{
  sops.secrets = {
    backupNbhwjKeyID1 = { };
    backupNbhwjKey1 = { };
    backupNbhwjRepo1 = { };
    backupNbhwjRepo1Password = { };
    backupNbhwjKeyID2 = { };
    backupNbhwjKey2 = { };
    backupNbhwjRepo2 = { };
    backupNbhwjRepo2Password = { };
  };
  systemd.services.backup-nbhwj = {
    description = "backup nbhwj";
    path = [ pkgs.ssh ];
    script = ''
      NBHWJ_KEY_ID1=$(< ${config.sops.secrets.backupNbhwjKeyID1.path}) \
      NBHWJ_KEY1=$(< ${config.sops.secrets.backupNbhwjKey1.path}) \
      NBHWJ_REPO1=$(< ${config.sops.secrets.backupNbhwjRepo1.path}) \
      NBHWJ_REPO1_PASSWORD=$(< ${config.sops.secrets.backupNbhwjRepo1Password.path}) \
      NBHWJ_KEY_ID2=$(< ${config.sops.secrets.backupNbhwjKeyID2.path}) \
      NBHWJ_KEY2=$(< ${config.sops.secrets.backupNbhwjKey2.path}) \
      NBHWJ_REPO2=$(< ${config.sops.secrets.backupNbhwjRepo2.path}) \
      NBHWJ_REPO2_PASSWORD=$(< ${config.sops.secrets.backupNbhwjRepo2Password.path}) \
      ssh -i /root/.ssh/id_nbhwj -o 'SendEnv NBHWJ_*' \
        wordpress-nbhwj@${nodes.s0.config.networking.fqdn}
    '';
    startAt = "*-*-* 05:00:00";
  };
}
