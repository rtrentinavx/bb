aws_ssm_region  = "us-east-1"
region          = "northeurope"
subscription_id = "ae301b3f-b6a8-4cf7-94da-acd4df9beed5"
transits = {
  "az-northeurope-transit-vnet" = {
    cidr            = "10.85.40.0/24"
    instance_size   = "Standard_D16_v3"
    account         = "rvb-dev-azure-acc"
    local_as_number = 64851
    fw_amount       = 2
  }
}

spokes = {
  "az-northeurope-prod-vnet" = {
    cidr            = "10.85.41.0/24"
    instance_size   = "Standard_D8_v3"
    account         = "rvb-dev-azure-acc"
    local_as_number = 64852
    vwan_connections = [
      {
        vwan_name     = "wan-prod",
        vwan_hub_name = "prod"
      }
    ]
  }
    "az-northeurope-non-prod-vnet" = {
    cidr            = "10.85.42.0/24"
    instance_size   = "Standard_D8_v3"
    account         = "rvb-dev-azure-acc"
    local_as_number = 64853
    vwan_connections = [
      {
        vwan_name     = "wan-non-prod",
        vwan_hub_name = "non-prod"
      }
    ]
  }
    "az-northeurope-infra-vnet" = {
    cidr            = "10.85.43.0/24"
    instance_size   = "Standard_D8_v3"
    account         = "rvb-dev-azure-acc"
    local_as_number = 64854
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
    virtual_hub_cidr = "10.85.44.0/24"
  }
  "non-prod" = {
    virtual_hub_cidr = "10.85.45.0/24"
  }
  "infra" = {
    virtual_hub_cidr = "10.85.46.0/24"
  }
}