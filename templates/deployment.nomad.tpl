{{- $Values := (ds "config") -}}

job "{{ $Values.name }}" {
  region      = "{{ $Values.region }}"
  datacenters = [{{ range $Values.datacenters }}"{{ . }}"{{ end }}]
  type        = "{{ $Values.type }}"

  group "{{ $Values.name }}" {
    count = {{ $Values.deployment.replicas }}
    network {
      mode = "host"
      {{- range $Values.services }}
      port "{{ .name }}" { {{ .type }} = {{ .port }} }
      {{- end }}
    }
    {{- range $Values.services }}
    service {
      name     = "{{ $Values.name }}-{{ .name }}"
      port     = "{{ .port }}"
      provider = "nomad"
      tags = [
        {{- range .tags }}
        "{{ . }}",
        {{- end }}
      ]
    }
    {{- end }}
    task "{{ $Values.name }}" {
      driver = "docker"
      config {
        image = "{{ $Values.image.repository }}:{{ $Values.image.tag }}"
        privileged = true
        ports = ["http", "metrics"]
        args = [
          {{- range $Values.deployment.args }}
          "{{ . }}",
          {{- end }}
        ]
      }
      template {
        destination = "${NOMAD_SECRETS_DIR}/env.vars"
        env         = true
        change_mode = "restart"
        data        = <<EOF
{{- range $Values.envFromSecrets }}
{{ printf "%s%s%s%s" `{{- with nomadVar "` .source `"` ` -}}` }}
{{ .target }}={{ `{{ .value }}` }}
{{ `{{- end -}}` }}
{{- end }}
EOF
      }
      resources {
        cpu    = {{ $Values.deployment.resources.cpu }}
        memory = {{ $Values.deployment.resources.memory }}
      }
    }
  }
}
