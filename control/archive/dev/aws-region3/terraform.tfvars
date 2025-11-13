aws_ssm_region = "us-west-2"

region = "eu-west-1"

tgws = {
  prod = {
    amazon_side_asn             = 64821
    transit_gateway_cidr_blocks = ["172.16.20.0/24"]
    create_tgw                  = true
    account_ids                 = []
  },
  non-prod = {
    amazon_side_asn             = 64822
    transit_gateway_cidr_blocks = ["172.16.21.0/24"]
    create_tgw                  = true
    account_ids                 = []
  }
  infra = {
    amazon_side_asn             = 64823
    transit_gateway_cidr_blocks = ["172.16.22.0/24"]
    create_tgw                  = true
    account_ids                 = []
  }
}
transits = {
  aws-eu-transit-prod = {
    account                 = "rvb-dev-aws-acc"
    cidr                    = "10.85.21.0/24"
    instance_size           = "c5n.xlarge"
    local_as_number         = 64824
    fw_amount               = 0
    firewall_image          = "Palo Alto Networks VM-Series Next-Generation Firewall (BYOL)"
    firewall_image_version  = "10.2.14"
    bootstrap_bucket_name_1 = ""
    tgw_name                = "prod,non-prod,infra"
    inside_cidr_blocks = {
      "prod" = {
        connect_peer_1    = "169.254.202.0/29"
        ha_connect_peer_1 = "169.254.202.8/29"
        connect_peer_2    = "169.254.202.16/29"
        ha_connect_peer_2 = "169.254.202.24/29"
      }
      "non-prod" = {
        connect_peer_1    = "169.254.202.32/29"
        ha_connect_peer_1 = "169.254.202.40/29"
        connect_peer_2    = "169.254.202.48/29"
        ha_connect_peer_2 = "169.254.202.56/29"
      }
      "infra" = {
        connect_peer_1    = "169.254.202.64/29"
        ha_connect_peer_1 = "169.254.202.72/29"
        connect_peer_2    = "169.254.202.80/29"
        ha_connect_peer_2 = "169.254.202.88/29"
    }
  },
}
}

#   aws-eu-transit-non-prod = {
#     account         = "rvb-dev-aws-acc"
#     cidr            = "10.85.22.0/24"
#     instance_size   = "t3.small"
#     local_as_number = 64825
#         fw_amount               = 0
#     firewall_image          = "Palo Alto Networks VM-Series Next-Generation Firewall (BYOL)"
#     firewall_image_version  = "10.2.14"
#     bootstrap_bucket_name_1 = ""
#     tgw_name        = "non-prod"
#     inside_cidr_blocks = {
#       "non-prod" = {
#         connect_peer_1    = "169.254.202.32/29"
#         ha_connect_peer_1 = "169.254.202.40/29"
#         connect_peer_2    = "169.254.202.48/29"
#         ha_connect_peer_2 = "169.254.202.56/29"
#       }
#     }
#   },
#   aws-eu-transit-infra = {
#     account         = "rvb-dev-aws-acc"
#     cidr            = "10.85.23.0/24"
#     instance_size   = "t3.small"
#     local_as_number = 64826
#         fw_amount               = 0
#     firewall_image          = "Palo Alto Networks VM-Series Next-Generation Firewall (BYOL)"
#     firewall_image_version  = "10.2.14"
#     bootstrap_bucket_name_1 = ""
#     tgw_name        = "infra"
#     inside_cidr_blocks = {
#       "infra" = {
#         connect_peer_1    = "169.254.202.64/29"
#         ha_connect_peer_1 = "169.254.202.72/29"
#         connect_peer_2    = "169.254.202.80/29"
#         ha_connect_peer_2 = "169.254.202.88/29"
#       }
#     }
#   }
# }