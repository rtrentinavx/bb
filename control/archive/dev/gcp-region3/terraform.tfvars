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
    gw_name             = "gcp-asia-south1-transit"
    project_id          = "360994900488"
    region              = "asia-south1"
    zone                = "asia-south1-a"
    ha_zone             = "asia-south1-b"
    name                = "transit-asia-south1"
    vpc_cidr            = "10.85.80.0/23"
    lan_cidr            = "10.85.82.0/24"
    mgmt_cidr           = "10.85.83.0/24"
    egress_cidr         = "10.85.84.0/24"
    gw_size             = "n2-highcpu-8"
    bgp_lan_subnets = {
      prod     = "10.85.85.0/24"
      non-prod = "10.85.86.0/24"
      infra    = "10.85.87.0/24"
    }
    cloud_router_asn        = 64890
    aviatrix_gw_asn         = 64891
    fw_amount               = 2
    firewall_image          = "Palo Alto Networks VM-Series Flex Next-Generation Firewall BYOL"
    firewall_image_version  = "10.2.10-h14"
    bootstrap_bucket_name_1 = ""
  }
]