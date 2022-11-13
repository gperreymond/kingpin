# KINGPIN

## build image

* APP_TERRAFORM_VERSION="1.3.4"
* APP_NOMAD_VERSION="1.4.2"
* APP_CNI_PLUGINS_VERSION="1.1.1"

```sh
$ docker build -f Dockerfile.runner -t kingpin-runner:1.0.0 .
```

## nomad server / client from docker-compose

```sh
$ ./docker-start.sh
$ ./docker-stop.sh
```

## runner usages

```sh
# nomad usage
$ ./nomad job run /local/traefik.hcl
$ ./nomad var put -force secret/global/nomad_address value=http://192.168.208.2:4646
```

## how to deploy ?

* create nomad variables as secrets
* create nomad hcl files
* deploy nomad jobs

```sh
# just one script
$ ./all-in-one.sh
```

## documentations

* https://docs.gomplate.ca/usage
* https://mpolinowski.github.io/docs/DevOps/Hashicorp/2021-08-07--hashicorp-nomad-job-configuration/2021-08-07