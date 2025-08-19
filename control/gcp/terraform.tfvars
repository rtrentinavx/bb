aws_ssm_region = "us-east-1"

hub_project_id = "rtrentin-01"

ncc_hubs = [
  { name = "interconnect", create = true },
  { name = "infra", create = true },
  { name = "non-prod", create = true },
  { name = "prod", create = true }
]

transits = [
  {
    access_account_name = "lab-test-gcp"
    gw_name             = "gcp-transit-central"
    project_id          = "rtrentin-01"
    region              = "us-central1"
    zone                = "us-central1-b"
    ha_zone             = "us-central1-c"
    name                = "transit-central"
    vpc_cidr            = "10.1.254.0/23"
    lan_cidr            = "10.1.252.0/23"
    mgmt_cidr           = "10.1.250.0/23"
    egress_cidr         = "10.1.248.0/23"
    gw_size             = "n2-highcpu-8"
    bgp_lan_subnets = {
      interconnect = "10.1.0.0/24"
      infra        = "10.1.1.0/24"
      non-prod     = "10.1.2.0/24"
      prod         = "10.1.3.0/24"
    }
    cloud_router_asn        = 65500
    aviatrix_gw_asn         = 65511
    fw_amount               = 2
    firewall_image          = "Palo Alto Networks VM-Series Flex Next-Generation Firewall BYOL"
    firewall_image_version  = "10.2.10-h14"
    bootstrap_bucket_name_1 = "lab-test-aviatrix-pan-bootstrap "
  }
]

spokes = [
  {
    vpc_name   = "rbk-infra"
    project_id = "rtrentin-01"
    ncc_hub    = "non-prod"
  }
]