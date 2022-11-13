#!/bin/bash

rm -rf local

files=charts/*.yaml
for file in $files; do
    filename=$(basename $file .yaml)
    echo "... $file => local/$filename.hcl"
    gomplate --datasource config=$file --file templates/deployment.nomad.tpl --out local/$filename.hcl
done
