#!/bin/bash

# -----------------------------------------------
echo "[INFO] create nomad variables as secrets"
# -----------------------------------------------

./generate-password.sh --source secret/keycloak --name postgres_password
./generate-password.sh --source secret/keycloak --name admin_password
./nomad var put -force secret/global/nomad_address value=http://172.20.0.5:4646

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