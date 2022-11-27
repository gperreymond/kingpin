region     = "europe-paris"
datacenter = "infra"
data_dir   = "/tmp/nomad/data"
name       = "node-client"
log_level  = "INFO"
log_json   = true
server {
  enabled = false
}
client {
  enabled = true
  server_join {
    retry_join     = ["192.168.49.20"]
    retry_max      = 3
    retry_interval = "15s"
  }
  meta {
    region      = "europe-paris"
    datacenter  = "infra"
    namespace   = "danone-bucharest"
  }
}
plugin "docker" {
  config {
    allow_privileged = true
    volumes {
      enabled = true
    }
    allow_caps = ["all"]
  }
}
advertise {
  http = "{{ GetPrivateIP }}:4646"
  rpc  = "{{ GetPrivateIP }}:4647"
  serf = "{{ GetPrivateIP }}:4648"
}
bind_addr = "0.0.0.0"
