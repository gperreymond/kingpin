#!/bin/bash

# -----------------------------------------------
echo "[INFO] create nomad variables as secrets"
# -----------------------------------------------

./generate-password.sh --source secret/keycloak --name postgres_password
./generate-password.sh --source secret/keycloak --name admin_password

# -----------------------------------------------
echo "[INFO] create nomad hcl files"
# -----------------------------------------------

./generate-files.sh

# -----------------------------------------------
echo "[INFO] deploy nomad jobs"
# -----------------------------------------------

files=local/*.hcl
for file in $files; do
    filename=$(basename $file .hcl)
    ./nomad job run /local/$filename.hcl
done