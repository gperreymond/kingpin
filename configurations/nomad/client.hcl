region     = "localhost"
datacenter = "kingpin"
data_dir   = "/opt/nomad/data"
name       = "node-client"
log_level  = "INFO"
log_json   = true
server {
  enabled = false
}
client {
  enabled = true
  server_join {
    retry_join     = ["nomad-server"]
    retry_max      = 3
    retry_interval = "15s"
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
  http = "172.20.0.15"
  rpc  = "172.20.0.15"
  serf = "172.20.0.15"
}
bind_addr = "0.0.0.0"
