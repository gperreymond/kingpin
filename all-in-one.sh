#!/bin/bash

# -----------------------------------------------
echo "[INFO] create nomad variables as secrets"
# -----------------------------------------------

./nomad var put -force secret/global/nomad_address value=http://192.168.208.2:4646

# -----------------------------------------------
echo "[INFO] create nomad hcl files"
# -----------------------------------------------

files=charts/*.yaml
for file in $files; do
    filename=$(basename $file .yaml)
    echo "... $file => local/$filename.hcl"
    gomplate --datasource config=$file --file templates/deployment.nomad.tpl --out local/$filename.hcl
done

# -----------------------------------------------
echo "[INFO] deploy nomad jobs"
# -----------------------------------------------

files=local/*.hcl
for file in $files; do
    filename=$(basename $file .hcl)
    ./nomad job run /local/$filename.hcl
done