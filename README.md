# KINGPIN

![KINGPIN LOGO](./logo.jpg)

## commands

```sh
# prepare kubernetes cluster
$ bin/minikube start --nodes 1 -p kingpin-demo
$ bin/minikube addons disable dashboard -p kingpin-demo
$ bin/minikube addons enable metrics-server -p kingpin-demo
$ ./bin/minikube ip -p kingpin-demo # in my case 192.168.49.2
$ bin/minikube addons enable metallb -p kingpin-demo
$ bin/minikube addons configure metallb -p kingpin-demo
# -- Enter Load Balancer Start IP: 192.168.49.20
# -- Enter Load Balancer End IP: 192.168.49.30

# kubernetes data-plane
$ kuma-2.0.0/bin/kumactl install control-plane | kubectl apply -f -
$ cat configurations/kubernetes/nomad.yaml | kubectl apply -f -

# kubernetes traefik
$ helm repo add traefik https://traefik.github.io/charts
$ helm repo update
$ kubectl create ns traefik-system
$ helm upgrade --install --namespace=traefik-system traefik traefik/traefik --version 20.5.2 -f configurations/kubernetes/traefik.yaml
$ kubectl apply -f configurations/kubernetes/traefik-manifests.yaml

# run client on local
# edit the client.hcl with the ip of the nomad load balancer (in my case 192.168.49.20)
$ export NOMAD_ADDR=http://192.168.49.20:4646
$ rm -rf /tmp/nomad
$ bin/nomad agent -config=configurations/nomad/client.hcl
```


## nomad usages

```sh
# nomad usage
$ bin/nomad system gc
$ bin/nomad server members
```

## generate random password

This script will generate a random password and add it to nomad variables as secrets.

```sh
$ ./scripts/generate-password --source secret/keycloak --name postgres_password
# force replacement
$ ./scripts/generate-password --source secret/keycloak --name postgres_password --force
```

## levant usage

```sh
$ bin/levant render -var-file=data/[name].yaml templates/deployment.nomad.hcl
```

## deploy all jobs

* create nomad variables as secrets
* create nomad hcl files
* deploy nomad jobs

```sh
# just one script
$ ./scripts/all-in-one
```

## documentations

* https://www.koyeb.com/blog/the-koyeb-serverless-engine-from-kubernetes-to-nomad-firecracker-and-kuma
* https://github.com/kelseyhightower/nomad-on-kubernetes
* https://doc.traefik.io/traefik/reference/static-configuration/env/
* https://mpolinowski.github.io/docs/category/hashicorp
* https://developer.hashicorp.com/nomad/docs/runtime/environment
* https://developer.hashicorp.com/nomad/docs/job-specification/template#environment-variables