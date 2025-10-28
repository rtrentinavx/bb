module "transit" {
  aws_ssm_region = "us-west-2"
  source         = "./modules/transit"
  hub_project_id = "rtrentin-01"
  ncc_hubs = [
    { name = "ai-1", create = true, preset_topology = "MESH" },
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
      }
      cloud_router_asn            = 16550
      aviatrix_gw_asn             = 65511
      fw_amount                   = 0
      firewall_image              = "Palo Alto Networks VM-Series Flex Next-Generation Firewall BYOL"
      firewall_image_version      = "10.2.10-h14"
      bootstrap_bucket_name_1     = ""
      manual_bgp_advertised_cidrs = ["0.0.0.0/0"]
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
      }
      cloud_router_asn            = 16550
      aviatrix_gw_asn             = 65512
      fw_amount                   = 0
      firewall_image              = "Palo Alto Networks VM-Series Flex Next-Generation Firewall BYOL"
      firewall_image_version      = "10.2.10-h14"
      bootstrap_bucket_name_1     = ""
      manual_bgp_advertised_cidrs = ["0.0.0.0/0"]
    }
  ]
}