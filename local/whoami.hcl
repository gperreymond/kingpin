job "whoami" {
  region      = "localhost"
  datacenters = ["kingpin"]
  type        = "service"

  group "whoami" {
    count = 1
    network {
      mode = "bridge"
      port "http" { to = 80 }
    }
    service {
      name     = "whoami-cluster"
      provider = "nomad"
      port     = "http"
    }
    task "whoami" {
      driver = "docker"
      config {
        image = "containous/whoami"
        privileged = true
       ports = ["http"]
      }
      resources {
        cpu    = 100
        memory = 128
      }
    }
  }
}