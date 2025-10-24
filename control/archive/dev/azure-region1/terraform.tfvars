aws_ssm_region  = "us-east-1"
region          = "canadaeast"
subscription_id = "ae301b3f-b6a8-4cf7-94da-acd4df9beed5"
transits = {
  "az-canadaeast-transit-vnet" = {
    cidr            = "10.85.30.0/24"
    instance_size   = "Standard_D16_v3"
    account         = "rvb-dev-azure-acc"
    local_as_number = 64841
    fw_amount       = 2
    firewall_image          = "Palo Alto Networks VM-Series Next-Generation Firewall (BYOL)"
    firewall_image_version  = "10.2.14"
    bootstrap_bucket_name_1 = ""
  }
}

spokes = {
  "az-canadaeast-prod-vnet" = {
    cidr            = "10.85.31.0/24"
    instance_size   = "Standard_D8_v3"
    account         = "rvb-dev-azure-acc"
    local_as_number = 64842
    vwan_connections = [
      {
        vwan_name     = "wan-prod",
        vwan_hub_name = "prod"
      }
    ]
  }
    "az-canadaeast-non-prod-vnet" = {
    cidr            = "10.85.32.0/24"
    instance_size   = "Standard_D8_v3"
    account         = "rvb-dev-azure-acc"
    local_as_number = 64843
    vwan_connections = [
      {
        vwan_name     = "wan-non-prod",
        vwan_hub_name = "non-prod"
      }
    ]
  }
    "az-canadaeast-infra-vnet" = {
    cidr            = "10.85.33.0/24"
    instance_size   = "Standard_D8_v3"
    account         = "rvb-dev-azure-acc"
    local_as_number = 64844
    vwan_connections = [
      {
        vwan_name     = "wan-infra",
        vwan_hub_name = "infra"
      }
    ]
  }
}

vwan_configs = {
  "vwan-prod" = {
    location            = "East US"
    resource_group_name = "rg-vwan-prod"
    existing            = false
  }
  "vwan-non-prod" = {
    location            = "East US"
    resource_group_name = "rg-vwan-non-prod"
    existing            = false
  }
  "vwan-infra" = {
    location            = "East US"
    resource_group_name = "rg-vwan-infra"
    existing            = false
  }
}

vwan_hubs = {
  "prod" = {
    virtual_hub_cidr = "10.85.34.0/24"
  }
  "non-prod" = {
    virtual_hub_cidr = "10.85.35.0/24"
  }
  "infra" = {
    virtual_hub_cidr = "10.85.36.0/24"
  }
}