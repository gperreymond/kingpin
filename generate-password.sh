#!/bin/bash

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -s|--source) source="$2"; shift ;;
        -n|--name) name="$2"; shift ;;
        -f|--force) force="-force"; shift ;;
        *) echo "[error] args not allowed"; exit 1;;
    esac
    shift
done

if [ -z "${source}" ]; then
    echo "[error] source is mandatory"
    exit 1
fi
if [ -z "${name}" ]; then
    echo "[error] name is mandatory"
    exit 1
fi

forceEnabled="false"
if [ "${force}" ]; then
    forceEnabled="true"
fi

echo "[INFO] source........ $source"
echo "[INFO] name.......... $name"
echo "[INFO] force......... $forceEnabled"

value=$(openssl rand -hex 20)
./nomad var put $force $source/$name value=$value
