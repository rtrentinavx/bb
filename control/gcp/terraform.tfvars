aws_ssm_region = "us-east-1"

hub_project_id = "rtrentin-01"

ncc_hubs = [
  { name = "ai-1", create = true },
  { name = "ai-2", create = true },
  { name = "ai-3", create = true },
  { name = "ai-4", create = true }
]

transits = [
  {
    access_account_name = "lab-test-gcp"
    gw_name             = "northamerica-northeast1"
    project_id          = "rtrentin-01"
    region              = "northamerica-northeast1"
    zone                = "northamerica-northeast1-b"
    ha_zone             = "northamerica-northeast1-c"
    name                = "na-northeast1-transit"
    vpc_cidr            = "10.1.254.0/23"
    lan_cidr            = "10.1.252.0/23"
    mgmt_cidr           = "10.1.250.0/23"
    egress_cidr         = "10.1.248.0/23"
    gw_size             = "n2-highcpu-8"
    bgp_lan_subnets = {
      ai-1 = "10.0.0.0/24"
      ai-2 = "10.1.1.0/24"
      ai-3 = "10.1.2.0/24"
      ai-4 = "10.1.3.0/24"
    }
    cloud_router_asn        = 16550
    aviatrix_gw_asn         = 65511
    fw_amount               = 2
    firewall_image          = "Palo Alto Networks VM-Series Flex Next-Generation Firewall BYOL"
    firewall_image_version  = "10.2.10-h14"
    bootstrap_bucket_name_1 = ""
  },
  {
    access_account_name = "lab-test-gcp"
    gw_name             = "europe-west1"
    project_id          = "rtrentin-01"
    region              = "europe-west1"
    zone                = "europe-west1-b"
    ha_zone             = "europe-west1-c"
    name                = "europe-west1"
    vpc_cidr            = "10.2.254.0/24"
    lan_cidr            = "10.2.252.0/24"
    mgmt_cidr           = "10.2.250.0/24"
    egress_cidr         = "10.2.248.0/24"
    gw_size             = "n2-highcpu-8"
    bgp_lan_subnets = {
      ai-1 = "10.2.0.0/24"
      ai-2 = "10.2.1.0/24"
      ai-3 = "10.2.2.0/24"
      ai-4 = "10.2.3.0/24"
    }
    cloud_router_asn        = 16550
    aviatrix_gw_asn         = 65512
    fw_amount               = 2
    firewall_image          = "Palo Alto Networks VM-Series Flex Next-Generation Firewall BYOL"
    firewall_image_version  = "10.2.10-h14"
    bootstrap_bucket_name_1 = ""
  }
]