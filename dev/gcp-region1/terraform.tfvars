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
    gw_name             = "us-northeast1-transit"
    project_id          = "200181776611"
    region              = "northamerica-northeast1"
    zone                = "northamerica-northeast1-a"
    ha_zone             = "northamerica-northeast1-b"
    name                = "us-northeast1-transit"
    vpc_cidr            = "10.85.60.0/23"
    lan_cidr            = "10.85.62.0/24"
    mgmt_cidr           = "10.85.63.0/24"
    egress_cidr         = "10.85.64.0/24"
    gw_size             = "n2-highcpu-8"
    bgp_lan_subnets = {
      prod         = "10.85.65.0/24"
      non-prod     = "10.85.66.0/24"
      infra        = "10.85.67.0/24"
    }
    cloud_router_asn        = 64870
    aviatrix_gw_asn         = 64871
    fw_amount               = 2
    firewall_image          = "Palo Alto Networks VM-Series Next-Generation Firewall (BYOL)"
    firewall_image_version  = "10.1.4-h13"
    # bootstrap_bucket_name_1 = ""
  }
]


spokes = [
  {
    vpc_name   = "prod"
    project_id = "200181776611"
    ncc_hub    = "prod"
  },
]
    # {
  #   vpc_name   = "ai-agent-dev"
  #   project_id = "200181776611"
  #   ncc_hub    = "ai-agent-dev"
  # }
  # {
  #   vpc_name   = "ai-agent-prod"
  #   project_id = "200181776611"
  #   ncc_hub    = "ai-agent-dev"
  # }


