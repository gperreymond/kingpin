job "traefik" {
  region      = "localhost"
  datacenters = ["kingpin"]
  type        = "system"

  group "traefik" {
    count = 1
    network {
      mode = "host"
      port "http" { static = 80 }
      port "metrics" { to = 8082 }
    }
    service {
      name     = "traefik-http"
      port     = "http"
      provider = "nomad"
      tags = [
        "traefik.enable=true",
        # Router
        "traefik.http.routers.traefik.rule=Host(`traefik.docker.localhost`)",
        "traefik.http.routers.traefik.service=api@internal",
        "traefik.http.services.traefik.loadbalancer.server.scheme=http",
        "traefik.http.services.traefik.loadbalancer.server.port=80"
      ]
    }
    service {
      name     = "traefik-metrics"
      port     = "metrics"
      provider = "nomad"
    }
    task "traefik" {
      driver = "docker"
      config {
        image = "traefik:v2.9.4"
        privileged = true
        ports = ["http", "metrics"]
        args = [
          "--global.sendAnonymousUsage=false",
          "--log.level=INFO",
          "--log.format=json",
          "--ping=true",
          "--ping.entryPoint=web",
          "--api.dashboard=true",
          "--api.insecure=true",
          "--entrypoints.web.address=:80",
          "--entryPoints.web.forwardedHeaders.insecure=true",
          "--entryPoints.metrics.address=:8082",
          "--providers.nomad=true",
          "--providers.nomad.exposedByDefault=false",
          "--providers.nomad.endpoint.address=http://192.168.192.2:4646",
          "--metrics.prometheus=true",
          "--metrics.prometheus.entryPoint=metrics",
          "--accesslog=true",
          "--accesslog.format=json",
          "--accesslog.fields.defaultmode=keep",
          "--accesslog.fields.headers.defaultmode=keep"
        ]
      }
      resources {
        cpu    = 100
        memory = 128
      }
    }
  }
}
