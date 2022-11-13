# KINGPIN

## build image

* APP_TERRAFORM_VERSION="1.3.4"
* APP_NOMAD_VERSION="1.4.2"
* APP_CNI_PLUGINS_VERSION="1.1.1"

```sh
$ docker build -f Dockerfile.runner -t kingpin-runner:1.0.0 .
```

## runner usages

```sh
# terraform usage
$ ./terraform apply /local/infra
# nomad usage
$ ./nomad job run /local/traefik.hcl
$ ./nomad var put secret/global nomad_address=http://192.168.208.2:4646
```

## gomplate usages

```sh
$ cat charts/traefik.yaml | gomplate --datasource config=stdin:///in.yaml --file templates/deployment.nomad.tpl
```

## documentations

* https://docs.gomplate.ca/usage
* https://mpolinowski.github.io/docs/DevOps/Hashicorp/2021-08-07--hashicorp-nomad-job-configuration/2021-08-07