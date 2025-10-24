aws_ssw_region = "us-west-2"

smarties = {
  "smart-group-1" = {
    cidr = "10.0.0.0/16"
  }
  "smart-group-2" = {
    cidr = "10.1.0.0/16"
  }
}

policies = {
  "policy-1" = {
    action           = "PERMIT"
    priority         = 10
    protocol         = "tcp"
    logging          = true
    watch            = false
    src_smart_groups = ["smart-group-1"]
    dst_smart_groups = ["smart-group-2"]
    port_ranges      = ["80", "443"]
  }
  "policy-2" = {
    action           = "DENY"
    priority         = 20
    protocol         = "icmp"
    logging          = true
    watch            = false
    src_smart_groups = ["smart-group-1"]
    dst_smart_groups = ["smart-group-2"]
    port_ranges      = []
  }
}