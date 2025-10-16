aws_ssm_region = "us-east-2"

hub_project_id = "rtrentin-01"

ncc_hubs = [
  { name = "ai-1", create = true },
  { name = "ai-2", create = true },
  { name = "ai-3", create = true },
  { name = "ai-4", create = true },
]

transits = [
  {
    access_account_name = "lab-test-gcp"
    gw_name             = "gcp-us-transit"
    project_id          = "rtrentin-01"
    region              = "us-east1"
    zone                = "us-east1-b"
    ha_zone             = "us-east1-c"
    name                = "gcp-us-transit"
    vpc_cidr            = "10.1.240.0/24"
    lan_cidr            = "10.1.241.0/24"
    mgmt_cidr           = "10.1.242.0/24"
    egress_cidr         = "10.1.243.0/24"
    gw_size             = "n2-highcpu-8"
    bgp_lan_subnets = {
      ai-1 = "10.1.0.0/24"
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
  # {
  #   access_account_name = "lab-test-gcp"
  #   gw_name             = "europe-west1"
  #   project_id          = "rtrentin-01"
  #   region              = "europe-west1"
  #   zone                = "europe-west1-b"
  #   ha_zone             = "europe-west1-c"
  #   name                = "europe-west1"
  #   vpc_cidr            = "10.2.254.0/24"
  #   lan_cidr            = "10.2.252.0/24"
  #   mgmt_cidr           = "10.2.250.0/24"
  #   egress_cidr         = "10.2.248.0/24"
  #   gw_size             = "n2-highcpu-8"
  #   bgp_lan_subnets = {
  #     ai-1 = "10.2.0.0/24"
  #     ai-2 = "10.2.1.0/24"
  #     ai-3 = "10.2.2.0/24"
  #     ai-4 = "10.2.3.0/24"
  #   }
  #   cloud_router_asn        = 16550
  #   aviatrix_gw_asn         = 65512
  #   fw_amount               = 2
  #   firewall_image          = "Palo Alto Networks VM-Series Flex Next-Generation Firewall BYOL"
  #   firewall_image_version  = "10.2.10-h14"
  #   bootstrap_bucket_name_1 = ""
  # },
  # {
  #   access_account_name = "lab-test-gcp"
  #   gw_name             = "asia-south1"
  #   project_id          = "rtrentin-01"
  #   region              = "asia-south1"
  #   zone                = "asia-south1-b"
  #   ha_zone             = "asia-south1-c"
  #   name                = "asia-south1"
  #   vpc_cidr            = "10.3.254.0/24"
  #   lan_cidr            = "10.3.252.0/24"
  #   mgmt_cidr           = "10.3.250.0/24"
  #   egress_cidr         = "10.3.248.0/24"
  #   gw_size             = "n2-highcpu-8"
  #   bgp_lan_subnets = {
  #     ai-1 = "10.3.0.0/24"
  #     ai-2 = "10.3.1.0/24"
  #     ai-3 = "10.3.2.0/24"
  #   }
  #   cloud_router_asn        = 16550
  #   aviatrix_gw_asn         = 65513
  #   fw_amount               = 2
  #   firewall_image          = "Palo Alto Networks VM-Series Flex Next-Generation Firewall BYOL"
  #   firewall_image_version  = "10.2.10-h14"
  #   bootstrap_bucket_name_1 = ""
  #}
]

spokes = [
  {
    vpc_name   = "na-northeast1-ai-1-w"
    project_id = "rtrentin-01"
    ncc_hub    = "ai-1"
  },
  {
    vpc_name   = "asia-south1-ai-2-w"
    project_id = "rtrentin-01"
    ncc_hub    = "ai-2"
  }
]
