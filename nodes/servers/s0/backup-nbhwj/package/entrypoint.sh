# shellcheck shell=bash
set -euo pipefail

# TODO: use SetCredentialEncrypted after systemd 258 is released
# https://github.com/systemd/systemd/issues/33318

# exec systemd-run \
# 	--user \
# 	--working-directory='@dir@' \
# 	--property="SetCredentialEncrypted=key-id1:$KEY_ID1" \
# 	--property="SetCredentialEncrypted=key1:$KEY1" \
# 	--property="SetCredentialEncrypted=repo1:$REPO1" \
# 	'@out@/libexec/backup'

umask a=,u=rw
dir=/run/backup-nbhwj
# shellcheck disable=SC2064
trap "rm -f '$dir'/{key-id1,key1,repo1,repo1-password,key-id2,key2,repo2,repo2-password}" EXIT
echo "$NBHWJ_KEY_ID1" >"$dir/key-id1"
echo "$NBHWJ_KEY1" >"$dir/key1"
echo "$NBHWJ_REPO1" >"$dir/repo1"
echo "$NBHWJ_REPO1_PASSWORD" >"$dir/repo1-password"
echo "$NBHWJ_KEY_ID2" >"$dir/key-id2"
echo "$NBHWJ_KEY2" >"$dir/key2"
echo "$NBHWJ_REPO2" >"$dir/repo2"
echo "$NBHWJ_REPO2_PASSWORD" >"$dir/repo2-password"

exec systemd-run \
	--user \
	--pipe \
	--quiet \
	--working-directory='@wordpressDir@' \
	--setenv="CREDENTIALS_DIRECTORY=$dir" \
	'@out@/libexec/backup'
