aws_ssm_region = "us-west-2"

hub_project_id = "200181776611"

ncc_hubs = [
  { name = "prod", create = true },
  { name = "non-prod", create = true },
  { name = "infra", create = true }
]

transits = [
  {
    access_account_name = "rvb-dev-gcp-acc"
    gw_name             = "gcp-europe-west1-transit"
    project_id          = "200181776611"
    region              = "europe-west1"
    zone                = "europe-west1-a"
    ha_zone             = "europe-west1-b"
    name                = "transit-europe-west1"
    vpc_cidr            = "10.85.80.0/23"
    lan_cidr            = "10.85.82.0/23"
    mgmt_cidr           = "10.85.84.0/23"
    egress_cidr         = "10.85.86.0/23"
    gw_size             = "n2-highcpu-8"
    bgp_lan_subnets = {
      prod         = "10.85.77.0/24"
      non-prod     = "10.85.78.0/24"
      infra        = "10.85.79.0/24"
    }
    cloud_router_asn        = 64880
    aviatrix_gw_asn         = 64881
    fw_amount               = 2
    firewall_image          = "Palo Alto Networks VM-Series Flex Next-Generation Firewall BYOL"
    firewall_image_version  = "10.1.4-h13"
    bootstrap_bucket_name_1 = ""
  }
]

spokes = [ {
  vpc_name   = "prod"
  project_id = "200181776611"
  ncc_hub    = "prod"
} ]