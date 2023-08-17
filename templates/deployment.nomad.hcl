job "[[ $.global.name ]]" {
  region = "[[ $.global.region ]]"
  datacenters = [
    "[[ $.global.datacenter ]]"
  ]
  namespace = "[[ $.global.namespace ]]"
  type = "[[ $.controller.type ]]"

  constraint {
    attribute = "$${meta.region}"
    value     = "[[ $.global.region ]]"
  }
  constraint {
    attribute = "$${meta.datacenter}"
    value     = "[[ $.global.datacenter ]]"
  }
  constraint {
    attribute = "$${meta.namespace}"
    value     = "[[ $.global.namespace ]]"
  }

  group "[[ $.global.name ]]" {
    count = [[ $.controller.replicas ]]
    [[- with $.services ]]
    network {
      mode = "bridge"
      [[- range $service := $.services ]]
      port "[[ $service.name ]]" { [[ or $service.type "to" ]] = [[ $service.port ]] }
      [[- end ]]
    }
    [[- end ]]
    [[- range $service := $.services ]]
    service {
      name = "[[ $.global.namespace ]]-[[ $.global.name ]]-[[ $service.name ]]"
      port = "[[ $service.name ]]"
      connect {
        sidecar_service {}
      }
      tags = [
      [[- range $tag := $service.tags ]]
        "[[ $tag ]]",
      [[- end ]]
      [[- with $service.ingress ]]
      [[- if .enabled ]]
        "traefik.enable=true",
        "traefik.http.routers.[[ $.global.namespace ]]-[[ $.global.name ]].rule=Host(`[[ $.global.name ]].[[ $.global.namespace ]].[[ $.global.dns.zone ]]`)",
        "traefik.http.routers.[[ $.global.namespace ]]-[[ $.global.name ]].entrypoints=web",
        "traefik.http.services.[[ $.global.namespace ]]-[[ $.global.name ]].loadbalancer.server.scheme=http"
      [[- end ]]
      [[- end ]]
      ]
    }
    [[- end ]]

    task "[[ $.global.name ]]" {
      driver = "docker"
      config {
        image = "[[ $.controller.image.repository ]]:[[ $.controller.image.tag ]]"
        privileged = true
        [[- with $.services ]]
        ports = [
          [[- range $service := $.services ]]
          "[[ .name ]]",
          [[- end ]]
        ]
        [[- end ]]
        [[- with $args := $.controller.args ]]
        args = [
          [[- range $arg := $args ]]
            "[[ $arg ]]",
          [[- end ]]
        ]
        [[- end ]]
      }
      [[- with $.env ]]
      template {
        destination = "local/env.vars"
        env = true
        change_mode = "restart"
        data = <<EOF
[[- range $key, $value := $.env ]]
[[ $key ]]="[[ $value ]]"
[[- end ]]
EOF
      }
      [[- end ]]
      [[- with $.envFromSecrets ]]
      template {
        destination = "secrets/envFromSecrets.vars"
        env = true
        change_mode = "restart"
        data = <<EOF
[[- range $.envFromSecrets ]]
[[ printf "%s%s%s%s" `{{- with nomadVar "` .source `"` ` }}` ]]
[[ .name ]]="[[ `{{ .value }}` ]]"
[[ `{{- end }}` ]]
[[- end ]]
EOF
      }
      [[- end ]]
      resources {
        cpu = [[ $.controller.resources.cpu ]]
        memory = [[ $.controller.resources.memory ]]
      }
    }
  }
}