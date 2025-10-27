module "transit" {
  aws_ssm_region = "us-west-2"
  source         = "./modules/transit"
  region         = "us-east-1"
  transits = {
    aws-transit-prod-1 = {
      account                 = "lab-test-aws"
      cidr                    = "10.0.0.0/23"
      instance_size           = "c5n.9xlarge"
      local_as_number         = 65011
      fw_amount               = 0
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
          connect_peer_3    = "169.254.103.0/29"
          ha_connect_peer_3 = "169.254.203.0/29"
          connect_peer_4    = "169.254.104.0/29"
          ha_connect_peer_4 = "169.254.204.0/29"
          connect_peer_5    = "169.254.105.0/29"
          ha_connect_peer_5 = "169.254.205.0/29"
          connect_peer_6    = "169.254.106.0/29"
          ha_connect_peer_6 = "169.254.206.0/29"
          connect_peer_7    = "169.254.107.0/29"
          ha_connect_peer_7 = "169.254.207.0/29"
          connect_peer_8    = "169.254.108.0/29"
          ha_connect_peer_8 = "169.254.208.0/29"
        }
      }
      manual_bgp_advertised_cidrs = ["0.0.0.0/0"]
    }
  }
  tgws = {
    prod = {
      amazon_side_asn             = 64512
      transit_gateway_cidr_blocks = ["172.16.0.0/24"]
      create_tgw                  = true
      account_ids                 = []
    }
  }
}

module "transit-west" {
  aws_ssm_region = "us-west-2"
  source         = "./modules/transit"
  region         = "us-west-1"
  tgws = {
    prod = {
      amazon_side_asn             = 64513
      transit_gateway_cidr_blocks = ["172.17.0.0/24"]
      create_tgw                  = true
      account_ids                 = []
    }
  }
  transits = {
    aws-transit-2 = {
      account         = "lab-test-aws"
      cidr            = "10.1.0.0/23"
      instance_size   = "c5n.9xlarge"
      local_as_number = 65012
      tgw_name        = "prod"
      inside_cidr_blocks = {
        "prod" = {
          connect_peer_1    = "169.254.11.0/29"
          ha_connect_peer_1 = "169.254.12.0/29"
          connect_peer_2    = "169.254.13.0/29"
          ha_connect_peer_2 = "169.254.14.0/29"
          connect_peer_3    = "169.254.21.0/29"
          ha_connect_peer_3 = "169.254.22.0/29"
          connect_peer_4    = "169.254.23.0/29"
          ha_connect_peer_4 = "169.254.24.0/29"
          connect_peer_5    = "169.254.15.0/29"
          ha_connect_peer_5 = "169.254.16.0/29"
          connect_peer_6    = "169.254.17.0/29"
          ha_connect_peer_6 = "169.254.18.0/29"
          connect_peer_7    = "169.254.25.0/29"
          ha_connect_peer_7 = "169.254.26.0/29"
          connect_peer_8    = "169.254.27.0/29"
          ha_connect_peer_8 = "169.254.28.0/29"
        }
      }
      manual_bgp_advertised_cidrs = ["0.0.0.0/0"]
    }
  }
}
