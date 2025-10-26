aws_ssm_region = "us-east-1"

region = "us-west-2"

tgws = {
  prod = {
    amazon_side_asn             = 64512
    transit_gateway_cidr_blocks = ["172.16.0.0/24"]
    create_tgw                  = true
    account_ids                 = []
  },
  non-prod = {
    amazon_side_asn             = 64513
    transit_gateway_cidr_blocks = ["172.17.0.0/24"]
    create_tgw                  = true
    account_ids                 = []
  }
  infra = {
    amazon_side_asn             = 64514
    transit_gateway_cidr_blocks = ["172.18.0.0/24"]
    create_tgw                  = true
    account_ids                 = []
  }
  #on-prem = {
  #  amazon_side_asn             = 65534
  #  transit_gateway_cidr_blocks = []
  #  create_tgw                  = false
  #  account_ids                 = []
  #}
}
transits = {
  aws-transit-1 = {
    account                 = "lab-test-aws"
    cidr                    = "10.0.0.0/23"
    instance_size           = "c5n.xlarge"
    local_as_number         = 65011
    fw_amount               = 2
    firewall_image          = "Palo Alto Networks VM-Series Next-Generation Firewall (BYOL)"
    firewall_image_version  = "10.2.14"
    bootstrap_bucket_name_1 = "test-lab-aviatrix-pan-bootstrap"
    tgw_name                = "prod"
    inside_cidr_blocks = {
      "prod" = {
        connect_peer_1    = "169.254.101.0/29"
        ha_connect_peer_1 = "169.254.201.0/29"
        connect_peer_2    = "169.254.102.0/29"
        ha_connect_peer_2 = "169.254.202.0/29"
      }
    }
  },
  #   aws-transit-2 = {
  #     account         = "lab-test-aws"
  #     cidr            = "10.1.0.0/23"
  #     instance_size   = "c5n.xlarge"
  #     local_as_number = 65012
  #     tgw_name        = "non-prod,infra"
  #     inside_cidr_blocks = {
  #       "non-prod" = {
  #         connect_peer_1    = "169.254.11.0/29"
  #         ha_connect_peer_1 = "169.254.12.0/29"
  #         connect_peer_2    = "169.254.13.0/29"
  #         ha_connect_peer_2 = "169.254.14.0/29"
  #       }
  #       "infra" = {
  #         connect_peer_1    = "169.254.15.0/29"
  #         ha_connect_peer_1 = "169.254.16.0/29"
  #         connect_peer_2    = "169.254.17.0/29"
  #         ha_connect_peer_2 = "169.254.18.0/29"
  #       }
  #       "on-prem" = {
  #         connect_peer_1    = "169.254.19.0/29"
  #         ha_connect_peer_1 = "169.254.20.0/29"
  #         connect_peer_2    = "169.254.21.0/29"
  #         ha_connect_peer_2 = "169.254.22.0/29"
  #       }
  #     }
  #   }
}

# external_devices = {
#   "onprem-router-active" = {
#     transit_key               = "transit1-vpc"
#     connection_name           = "to-onprem-router"
#     remote_gateway_ip         = "203.0.113.10"
#     bgp_enabled               = true
#     bgp_remote_asn            = "65010"
#     local_tunnel_cidr         = "169.254.1.1/30,169.254.1.5/30"
#     remote_tunnel_cidr        = "169.254.1.2/30,169.254.1.6/30"
#     ha_enabled                = false 
#     enable_ikev2              = true
#     inspected_by_firenet      = true
#   }
#   "onprem-router-standby" = {
#     transit_key               = "transit1-vpc"
#     connection_name           = "to-onprem-router"
#     remote_gateway_ip         = "203.0.113.11"
#     bgp_enabled               = true
#     bgp_remote_asn            = "65010"
#     local_tunnel_cidr         = "169.254.1.1/30,169.254.1.5/30"
#     remote_tunnel_cidr        = "169.254.1.2/30,169.254.1.6/30"
#     ha_enabled                = false
#     enable_ikev2              = true
#     inspected_by_firenet      = true
#   }
#   "onprem-router-3" = {
#     transit_key               = "transit1-vpc"
#     connection_name           = "to-onprem-router"
#     remote_gateway_ip         = "203.0.113.12"
#     bgp_enabled               = true
#     bgp_remote_asn            = "65010"
#     local_tunnel_cidr         = "169.254.1.1/30,169.254.1.5/30"
#     remote_tunnel_cidr        = "169.254.1.2/30,169.254.1.6/30"
#     ha_enabled                = true
#     backup_remote_gateway_ip  = "203.0.113.11"
#     backup_local_tunnel_cidr  = "169.254.1.9/30,169.254.1.13/30"
#     backup_remote_tunnel_cidr = "169.254.1.10/30,169.254.1.14/30"
#     enable_ikev2              = true
#     inspected_by_firenet      = true
#   }
# }