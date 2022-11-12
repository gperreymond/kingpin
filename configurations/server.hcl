region = "localhost"
datacenter = "kingpin"
data_dir = "/opt/nomad/data"
name = "node-server"
log_level = "INFO"
log_json = true
server {
  enabled = true
  bootstrap_expect = 1
}
client {
  enabled = false
}
telemetry {
  prometheus_metrics         = true
  publish_allocation_metrics = true
  publish_node_metrics       = true
}
advertise {
  http = "{{ GetPrivateIP }}"
  rpc  = "{{ GetPrivateIP }}"
  serf = "{{ GetPrivateIP }}"
}
bind_addr = "0.0.0.0"
