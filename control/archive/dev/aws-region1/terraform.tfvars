aws_ssm_region = "us-east-1"

region = "ap-south-1"

tgws = {
  prod = {
    amazon_side_asn             = 64801
    transit_gateway_cidr_blocks = ["172.16.0.0/24"]
    create_tgw                  = true
    account_ids                 = [""]
  },
  non-prod = {
    amazon_side_asn             = 64802
    transit_gateway_cidr_blocks = ["172.16.1.0/24"]
    create_tgw                  = true
    account_ids                 = []
  }
  infra = {
    amazon_side_asn             = 64803
    transit_gateway_cidr_blocks = ["172.16.2.0/24"]
    create_tgw                  = true
    account_ids                 = [""]
  }
}
transits = {
  aws-ap-transit-prod = {
    account                 = "rvb-dev-aws-acc"
    cidr                    = "10.85.1.0/24"
    instance_size           = "t3.small"
    local_as_number         = 64804
    fw_amount               = 0
    firewall_image          = "Palo Alto Networks VM-Series Next-Generation Firewall (BYOL)"
    firewall_image_version  = "10.2.14"
    bootstrap_bucket_name_1 = ""
    tgw_name                = "prod"
    inside_cidr_blocks = {
      "prod" = {
        connect_peer_1    = "169.254.200.0/29"
        ha_connect_peer_1 = "169.254.200.8/29"
        connect_peer_2    = "169.254.200.16/29"
        ha_connect_peer_2 = "169.254.200.24/29"
      }
    }
  },
  aws-ap-transit-non-prod = {
    account         = "rvb-dev-aws-acc"
    cidr            = "10.85.2.0/24"
    instance_size   = "t3.small"
    local_as_number = 64805
    fw_amount               = 0
    firewall_image          = "Palo Alto Networks VM-Series Next-Generation Firewall (BYOL)"
    firewall_image_version  = "10.2.14"
    bootstrap_bucket_name_1 = ""
    tgw_name        = "non-prod"
    inside_cidr_blocks = {
      "non-prod" = {
        connect_peer_1    = "169.254.200.32/29"
        ha_connect_peer_1 = "169.254.200.40/29"
        connect_peer_2    = "169.254.200.48/29"
        ha_connect_peer_2 = "169.254.200.56/29"
      }
    }
  },
  aws-ap-transit-infra = {
    account         = "rvb-dev-aws-acc"
    cidr            = "10.85.3.0/24"
    instance_size   = "t3.small"
    local_as_number = 64806
    fw_amount               = 0
    firewall_image          = "Palo Alto Networks VM-Series Next-Generation Firewall (BYOL)"
    firewall_image_version  = "10.2.14"
    bootstrap_bucket_name_1 = ""
    tgw_name        = "infra"
    inside_cidr_blocks = {
      "infra" = {
        connect_peer_1    = "169.254.200.64/29"
        ha_connect_peer_1 = "169.254.200.72/29"
        connect_peer_2    = "169.254.200.80/29"
        ha_connect_peer_2 = "169.254.200.88/29"
      }
    }
  }
}