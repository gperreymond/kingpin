{{- $Values := (ds "config") -}}

job "{{ $Values.name }}" {
  region      = "{{ $Values.region }}"
  datacenters = [{{ range $Values.datacenters }}"{{ . }}",{{ end }}]
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
      {{- with .tags }}
      tags = [
        {{- range . }}
        "{{ . }}",
        {{- end }}
      ]
      {{- end }}
    }
    {{- end }}
    task "{{ $Values.name }}" {
      driver = "docker"
      config {
        image = "{{ $Values.image.repository }}:{{ $Values.image.tag }}"
        privileged = true
        ports = [{{ range $Values.services }}"{{ .name }}",{{ end }}]
        {{- with $Values.deployment.args }}
        args = [
          {{- range . }}
          "{{ . }}",
          {{- end }}
        ]
        {{- end }}
      }
      template {
        destination = "${NOMAD_SECRETS_DIR}/env.vars"
        env         = true
        change_mode = "restart"
        data        = <<EOF
# classic key=value
{{- range $key, $value := $Values.env }}
{{ $key }}="{{ $value }}"
{{- end }}
# from nomad var
{{- range $Values.envFromSecrets }}
{{ printf "%s%s%s%s" `{{- with nomadVar "` .source `"` ` }}` }}
{{ .name }}="{{ `{{ .value }}` }}"
{{ `{{- end }}` }}
{{- end }}
# from nomad service
{{- range $Values.envFromServices }}
{{ printf "%s%s%s%s" `{{- range nomadService "` .source `"` ` }}` }}
{{ .name }}="{{ .value }}"
{{ `{{- end }}` }}
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
