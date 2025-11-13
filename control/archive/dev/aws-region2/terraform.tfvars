aws_ssm_region = "us-west-2"

region = "ca-central-1"

tgws = {
  prod = {
    amazon_side_asn             = 64811
    transit_gateway_cidr_blocks = ["172.16.10.0/24"]
    create_tgw                  = true
    account_ids                 = []
  },
  non-prod = {
    amazon_side_asn             = 64812
    transit_gateway_cidr_blocks = ["172.16.11.0/24"]
    create_tgw                  = true
    account_ids                 = []
  }
  infra = {
    amazon_side_asn             = 64813
    transit_gateway_cidr_blocks = ["172.16.12.0/24"]
    create_tgw                  = true
    account_ids                 = []
  }
}
transits = {
  aws-ca-transit-prod = {
    account                 = "rvb-dev-aws-acc"
    cidr                    = "10.85.11.0/24"
    instance_size           = "c5n.xlarge"
    local_as_number         = 64814
    fw_amount               = 0
    firewall_image          = "Palo Alto Networks VM-Series Next-Generation Firewall (BYOL)"
    firewall_image_version  = "10.2.14"
    bootstrap_bucket_name_1 = ""
    tgw_name                = "prod,non-prod,infra"
    inside_cidr_blocks = {
      "prod" = {
        connect_peer_1    = "169.254.201.0/29"
        ha_connect_peer_1 = "169.254.201.8/29"
        connect_peer_2    = "169.254.201.16/29"
        ha_connect_peer_2 = "169.254.201.24/29"
      },
      "non-prod" = {
        connect_peer_1    = "169.254.201.32/29"
        ha_connect_peer_1 = "169.254.201.40/29"
        connect_peer_2    = "169.254.201.48/29"
        ha_connect_peer_2 = "169.254.201.56/29"
      }
      "infra" = {
        connect_peer_1    = "169.254.201.64/29"
        ha_connect_peer_1 = "169.254.201.72/29"
        connect_peer_2    = "169.254.201.80/29"
        ha_connect_peer_2 = "169.254.201.88/29"
      }
      }
    }
  }

  # aws-ca-transit-non-prod = {
  #   account         = "rvb-dev-aws-acc"
  #   cidr            = "10.85.12.0/24"
  #   instance_size   = "t3.small"
  #   local_as_number = 64815
  #       fw_amount               = 0
  #   firewall_image          = "Palo Alto Networks VM-Series Next-Generation Firewall (BYOL)"
  #   firewall_image_version  = "10.2.14"
  #   bootstrap_bucket_name_1 = ""
  #   tgw_name        = "non-prod"
  #   inside_cidr_blocks = {
  #     "non-prod" = {
  #       connect_peer_1    = "169.254.201.32/29"
  #       ha_connect_peer_1 = "169.254.201.40/29"
  #       connect_peer_2    = "169.254.201.48/29"
  #       ha_connect_peer_2 = "169.254.201.56/29"
  #     }
  #   }
  # },
  # aws-ca-transit-infra = {
  #   account         = "rvb-dev-aws-acc"
  #   cidr            = "10.85.13.0/24"
  #   instance_size   = "t3.small"
  #   local_as_number = 64816
  #       fw_amount               = 0
  #   firewall_image          = "Palo Alto Networks VM-Series Next-Generation Firewall (BYOL)"
  #   firewall_image_version  = "10.2.14"
  #   bootstrap_bucket_name_1 = ""
  #   tgw_name        = "infra"
  #   inside_cidr_blocks = {
  #     "infra" = {
  #       connect_peer_1    = "169.254.201.64/29"
  #       ha_connect_peer_1 = "169.254.201.72/29"
  #       connect_peer_2    = "169.254.201.80/29"
  #       ha_connect_peer_2 = "169.254.201.88/29"
  #     }
  #   }
  # }
