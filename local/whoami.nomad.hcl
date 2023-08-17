job "whoami" {
  region = "europe-stockholm"
  datacenters = [
    "infra"
  ]
  namespace = "kingpin"
  type = "service"

  constraint {
    attribute = "$${meta.region}"
    value     = "europe-stockholm"
  }
  constraint {
    attribute = "$${meta.datacenter}"
    value     = "infra"
  }
  constraint {
    attribute = "$${meta.namespace}"
    value     = "kingpin"
  }

  group "whoami" {
    count = 1
    network {
      mode = "bridge"
      port "http" { to = 80 }
    }
    service {
      name = "kingpin-whoami-http"
      port = "http"
      connect {
        sidecar_service {}
      }
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.kingpin-whoami.rule=Host(`whoami.kingpin.metronlab.eu`)",
        "traefik.http.routers.kingpin-whoami.entrypoints=web",
        "traefik.http.services.kingpin-whoami.loadbalancer.server.scheme=http"
      ]
    }

    task "whoami" {
      driver = "docker"
      config {
        image = "traefik/whoami:v1.8.7"
        privileged = true
        ports = [
          "http",
        ]
      }
      resources {
        cpu = 100
        memory = 64
      }
    }
  }
}