# KINGPIN

## build image

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
$ ./nomad system gc
$ ./nomad server members
```

## generate random password

This script will generate a random password and add it to nomad variables as secrets.

```sh
$ ./generate-password.sh --source secret/keycloak --name postgres_password
# force replacement
$ ./generate-password.sh --source secret/keycloak --name postgres_password --force
```

## deploy all jobs

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

* https://developer.hashicorp.com/nomad/docs/runtime/environment
* https://developer.hashicorp.com/nomad/docs/job-specification/template#environment-variables