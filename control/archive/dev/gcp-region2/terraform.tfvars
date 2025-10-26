aws_ssm_region = "us-east-1"

hub_project_id = "360994900488"

ncc_hubs = [
  { name = "prod", create = false },
  { name = "non-prod", create = false },
  { name = "infra", create = false }
]

transits = [
  {
    access_account_name = "rvb-dev-gcp-acc"
    gw_name             = "gcp-europe-west1-transit"
    project_id          = "360994900488"
    region              = "europe-west1"
    zone                = "europe-west1-a"
    ha_zone             = "europe-west1-b"
    name                = "transit-europe-west1"
    vpc_cidr            = "10.85.70.0/23"
    lan_cidr            = "10.85.72.0/24"
    mgmt_cidr           = "10.85.73.0/24"
    egress_cidr         = "10.85.74.0/24"
    gw_size             = "n2-highcpu-8"
    bgp_lan_subnets = {
      prod     = "10.85.75.0/24"
      non-prod = "10.85.76.0/24"
      infra    = "10.85.77.0/24"
    }
    cloud_router_asn        = 64880
    aviatrix_gw_asn         = 64881
    fw_amount               = 2
    firewall_image          = "Palo Alto Networks VM-Series Flex Next-Generation Firewall BYOL"
    firewall_image_version  = "10.2.10-h14"
    bootstrap_bucket_name_1 = ""
  }
]