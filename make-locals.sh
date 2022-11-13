#!/bin/bash

gomplate --datasource config=charts/traefik.yaml --file templates/deployment.nomad.tpl --out local/traefik.hcl