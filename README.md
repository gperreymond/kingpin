# KINGPIN

## build image

* APP_TERRAFORM_VERSION="1.3.4"
* APP_NOMAD_VERSION="1.4.2"
* APP_CNI_PLUGINS_VERSION="1.1.1"

```sh
$ docker build -f Dockerfile.runner -t kingpin-runner:1.0.0 .
```

## runner usage

```sh
# terraform usage
$ ./terraform apply /local/infra
#nomad usage
$ ./nomad job run /local/traefik.hcl
```