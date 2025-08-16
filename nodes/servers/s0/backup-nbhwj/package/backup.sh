# shellcheck shell=bash
set -euo pipefail

(
	umask a=,u=rw
	mariadb-dump '@dbName@' >db.sql
)
AWS_ACCESS_KEY_ID=$(<"$CREDENTIALS_DIRECTORY/key-id1") \
AWS_SECRET_ACCESS_KEY=$(<"$CREDENTIALS_DIRECTORY/key1") \
RESTIC_REPOSITORY_FILE=$CREDENTIALS_DIRECTORY/repo1 \
RESTIC_PASSWORD_FILE=$CREDENTIALS_DIRECTORY/repo1-password \
RESTIC_CACHE_DIR=@cacheDir@ \
	restic backup . --skip-if-unchanged --no-scan

AWS_ACCESS_KEY_ID=$(<"$CREDENTIALS_DIRECTORY/key-id2") \
AWS_SECRET_ACCESS_KEY=$(<"$CREDENTIALS_DIRECTORY/key2") \
RESTIC_REPOSITORY_FILE=$CREDENTIALS_DIRECTORY/repo2 \
RESTIC_PASSWORD_FILE=$CREDENTIALS_DIRECTORY/repo2-password \
RESTIC_CACHE_DIR=@cacheDir@ \
	restic backup . --skip-if-unchanged --no-scan
