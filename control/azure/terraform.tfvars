subscription_id = "47ab116c-8c15-4453-b06a-3fecd09ebda9"
transits = {
  "azure-east-transit-vnet" = {
    cidr            = "10.1.0.0/16"
    region          = "East US"
    instance_size   = "Standard_D3_v2"
    account         = "lab-test-azure"
    local_as_number = 65001
    fw_amount       = 0
    vwan_connections = [
      {
        vwan_name     = "infra"
        vwan_hub_name = "infra"
      }
    ]
  }
}

spokes = {
  "azure-spoke1-vnet" = {
    cidr            = "10.6.0.0/16"
    region          = "East US"
    instance_size   = "Standard_D3_v2"
    account         = "lab-test-azure"
    local_as_number = 65002
    vwan_connections = [
      {
        vwan_name     = "prod",
        vwan_hub_name = "prod"
      }
    ]
  }
}

vwan_hubs = {
  "infra" = {
    location         = "East US"
    virtual_hub_cidr = "10.2.0.0/24"
    subscription_id  = "47ab116c-8c15-4453-b06a-3fecd09ebda9"
  }
  "non-prod" = {
    location                               = "East US"
    virtual_hub_cidr                       = "10.3.0.0/24"
    subscription_id                        = "47ab116c-8c15-4453-b06a-3fecd09ebda9"
    virtual_router_auto_scale_min_capacity = 4
  }
  "prod" = {
    location         = "East US"
    virtual_hub_cidr = "10.3.0.0/24"
  }
}

vnets = {
  "workload1-vnet" = {
    cidr            = "10.3.0.0/16"
    private_subnets = ["10.3.1.0/24", "10.3.2.0/24"]
    public_subnets  = ["10.3.3.0/24", "10.3.4.0/24"]
    vwan_name       = "infra"
    vwan_hub_name   = "infra"
    region          = "East US"
  }
  "workload2-vnet" = {
    resource_group_name = "rg-vnet-workload2-vnet-eastus"
    vwan_name           = "prod"
    vwan_hub_name       = "prod"
    region              = "East US"
    existing            = true
  }
}