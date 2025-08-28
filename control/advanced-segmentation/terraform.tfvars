aws_ssw_region = "us-east-1"
region         = "us-west-2"
policies = {
  "allow-prod-ping" = {
    action           = "PERMIT"
    priority         = 2
    protocol         = "icmp"
    logging          = true
    watch            = false
    src_smart_groups = ["infra"]
    dst_smart_groups = ["prod"]
    port_ranges      = []
  }
}