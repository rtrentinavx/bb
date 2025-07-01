tgws = {
  prod = {
    amazon_side_asn             = 64512
    region                      = "us-east-1"
    transit_gateway_cidr_blocks = ["172.16.0.0/24"]
    create_tgw                  = true
  },
  non-prod = {
    amazon_side_asn             = 64513
    region                      = "us-east-1"
    transit_gateway_cidr_blocks = ["172.17.0.0/24"]
    create_tgw                  = true
  }
  infra = {
    amazon_side_asn             = 64514
    region                      = "us-east-1"
    transit_gateway_cidr_blocks = ["172.18.0.0/24"]
    create_tgw                  = true
  }
  on-prem = {
    amazon_side_asn             = 65534
    region                      = "us-east-1"
    transit_gateway_cidr_blocks = ["172.19.0.0/24"]
    create_tgw                  = false
  }
}
transits = {
  transit1-vpc = {
    account         = "lab-test-aws"
    cidr            = "10.0.0.0/23"
    region          = "us-east-1"
    instance_size   = "c5n.xlarge"
    local_as_number = 65011
    fw_amount       = 2
    tgw_name        = "prod"
    inside_cidr_blocks = {
      "prod" = {
        connect_peer_1    = "169.254.101.0/29"
        ha_connect_peer_1 = "169.254.201.0/29"
        connect_peer_2    = "169.254.102.0/29"
        ha_connect_peer_2 = "169.254.202.0/29"
      }
    }
  },
  transit2-vpc = {
    account         = "lab-test-aws"
    cidr            = "10.1.0.0/23"
    region          = "us-east-1"
    instance_size   = "c5n.xlarge"
    local_as_number = 65012
    tgw_name        = "non-prod,infra,on-prem"
    inside_cidr_blocks = {
      "non-prod" = {
        connect_peer_1    = "169.254.11.0/29"
        ha_connect_peer_1 = "169.254.12.0/29"
        connect_peer_2    = "169.254.13.0/29"
        ha_connect_peer_2 = "169.254.14.0/29"
      }
      "infra" = {
        connect_peer_1    = "169.254.15.0/29"
        ha_connect_peer_1 = "169.254.16.0/29"
        connect_peer_2    = "169.254.17.0/29"
        ha_connect_peer_2 = "169.254.18.0/29"
      }
      "on-prem" = {
        connect_peer_1    = "169.254.19.0/29"
        ha_connect_peer_1 = "169.254.20.0/29"
        connect_peer_2    = "169.254.21.0/29"
        ha_connect_peer_2 = "169.254.22.0/29"
      }
    }
  }
}
vpcs = {
  #   vpc1 = {
  #     cidr            = "10.2.0.0/24"
  #     region          = "us-east-1"
  #     tgw_key         = "prod"
  #     private_subnets = ["10.2.0.0/26", "10.2.0.64/26"]
  #     public_subnets  = ["10.2.0.128/26", "10.2.0.192/26"]
  #   },
  #   vpc2 = {
  #     cidr            = "10.3.0.0/24"
  #     region          = "us-east-1"
  #     tgw_key         = "non-prod"
  #     private_subnets = ["10.3.0.0/26", "10.3.0.64/26"]
  #     public_subnets  = ["10.3.0.128/26", "10.3.0.192/26"]
  #   }
  vpc3 = {
    cidr            = "10.4.0.0/24"
    region          = "us-east-1"
    tgw_key         = "infra"
    private_subnets = ["10.4.0.0/26", "10.4.0.64/26"]
    public_subnets  = ["10.4.0.128/26", "10.4.0.192/26"]
  }
}