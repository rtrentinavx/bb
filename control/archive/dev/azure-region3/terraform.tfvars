aws_ssm_region  = "us-east-1"
region          = "southindia"
subscription_id = "ae301b3f-b6a8-4cf7-94da-acd4df9beed5"
transits = {
  "az-southindia-transit-vnet" = {
    cidr            = "10.85.50.0/24"
    instance_size   = "Standard_D16_v3"
    account         = "rvb-dev-azure-acc"
    local_as_number = 64861
    fw_amount       = 2
  }
}

spokes = {
  "az-southindia-prod-vnet" = {
    cidr            = "10.85.51.0/24"
    instance_size   = "Standard_D8_v3"
    account         = "rvb-dev-azure-acc"
    local_as_number = 64862
    vwan_connections = [
      {
        vwan_name     = "wan-prod",
        vwan_hub_name = "prod"
      }
    ]
  }
  "az-southindia-non-prod-vnet" = {
    cidr            = "10.85.52.0/24"
    instance_size   = "Standard_D8_v3"
    account         = "rvb-dev-azure-acc"
    local_as_number = 64863
    vwan_connections = [
      {
        vwan_name     = "wan-non-prod",
        vwan_hub_name = "non-prod"
      }
    ]
  }
  "az-southindia-infra-vnet" = {
    cidr            = "10.85.53.0/24"
    instance_size   = "Standard_D8_v3"
    account         = "rvb-dev-azure-acc"
    local_as_number = 64864
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
    existing            = true
  }
  "vwan-non-prod" = {
    location            = "East US"
    resource_group_name = "rg-vwan-non-prod"
    existing            = true
  }
  "vwan-infra" = {
    location            = "East US"
    resource_group_name = "rg-vwan-infra"
    existing            = true
  }
}

vwan_hubs = {
  "prod" = {
    virtual_hub_cidr = "10.85.54.0/24"
  }
  "non-prod" = {
    virtual_hub_cidr = "10.85.55.0/24"
  }
  "infra" = {
    virtual_hub_cidr = "10.85.56.0/24"
  }
}