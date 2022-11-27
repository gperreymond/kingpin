job "[[ $.global.name ]]" {
  region = "[[ $.global.region ]]"
  datacenters = [
    "[[ $.global.datacenter ]]"
  ]
  // namespace = "[[ $.global.namespace ]]"
  type = "[[ $.controller.type ]]"

  constraint {
    attribute = "$${meta.region}"
    value     = "[[ $.global.region ]]"
  }
  constraint {
    attribute = "$${meta.datacenter}"
    value     = "[[ $.global.datacenter ]]"
  }
  // constraint {
  //   attribute = "$${meta.namespace}"
  //   value     = "[[ $.global.namespace ]]"
  // }

  group "[[ $.global.name ]]" {
    count = [[ $.controller.replicas ]]
    [[- with $.services ]]
    network {
      mode = "host"
      [[- range $service := $.services ]]
      port "[[ $service.name ]]" { [[ or $service.type "to" ]] = [[ $service.port ]] }
      [[- end ]]
    }
    [[- end ]]
    [[- range $service := $.services ]]
    service {
      name = "[[ $.global.name ]]-[[ $service.name ]]"
      provider = "nomad"
      port = "[[ $service.name ]]"
      tags = [
      [[- range $tag := $service.tags ]]
        "[[ $tag ]]",
      [[- end ]]
      [[- with $service.ingress ]]
      [[- if .enabled ]]
        "traefik.enable=true",
        "traefik.http.routers.[[ $.global.name ]].rule=Host(`[[ .prefix ]].[[ $.global.namespace ]].[[ $.global.baseUrl ]]`)",
        "traefik.http.services.[[ $.global.name ]].loadbalancer.server.port=${NOMAD_HOST_PORT_[[ $.global.name ]]-[[ $service.name ]]}",
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
      [[- with $.envFromServices ]]
      template {
        destination = "local/envFromServices.vars"
        env = true
        change_mode = "restart"
        data = <<EOF
[[- range $.envFromServices ]]
[[ printf "%s%s%s%s" `{{- range nomadService "` .source `"` ` }}` ]]
[[ .name ]]="[[ .value ]]"
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
    [[- if $.mesh.enabled ]]
    task "kuma-proxy" {
      driver = "docker"
      config {
        image = "docker.io/kumahq/kuma-dp:2.0.0"
        privileged = true
        args = [
          "run",
          "--cp-address=${APP_KUMA_CONTROL_PLANE_ADDRESS}",
          "--dns-enabled=false",
          "--dataplane-file=/etc/kuma/data-plane.yaml"
        ]
        volumes = [
          "local/data-plane.yaml:/etc/kuma/data-plane.yaml:ro"
        ]
      }
      template {
        destination = "local/env.vars"
        env = true
        change_mode = "restart"
        data = <<EOF
{{- range nomadService "kuma-http" }}
APP_KUMA_CONTROL_PLANE_ADDRESS="http://{{ .Address }}:5678"
{{- end }}
EOF
      }
      template {
        destination = "local/data-plane.yaml"
        change_mode = "restart"
        data        = <<EOH
type: Dataplane
mesh: default
name: [[ $.global.name ]]-[[ $.global.datacenter ]]-[[ $.global.namespace ]]
networking:
  address: $${NOMAD_HOST_IP_[[ $.mesh.service ]]}
  inbound: 
    - port: 80
      {{- range nomadService "[[ $.global.name ]]-[[ $.mesh.service ]]" }}
      servicePort: {{ .Port }}
      serviceAddress: {{ .Address }}
      {{- end }}
      tags: 
        kuma.io/service: [[ $.global.name ]]-[[ $.global.datacenter ]]-[[ $.global.namespace ]]
        kuma.io/protocol: http
EOH
      }
      resources {
        cpu = 100
        memory = 64
      }
    }
    [[- end ]]
  }
}