subscription_id = "47ab116c-8c15-4453-b06a-3fecd09ebda9"
transits = {
  "azure-eastus-transit-vnet" = {
    cidr            = "10.1.0.0/16"
    region          = "East US"
    instance_size   = "Standard_D5_v2"
    account         = "lab-test-azure"
    local_as_number = 65001
    fw_amount       = 2
    vwan_connections = [
      {
        vwan_name     = "vwan-infra"
        vwan_hub_name = "infra"
      }
    ]
  }
}

spokes = {
  "azure-spoke2-vnet" = {
    cidr            = "10.17.0.0/23"
    region          = "East US"
    instance_size   = "Standard_D3_v2"
    account         = "lab-test-azure"
    local_as_number = 65002
    vwan_connections = [
      {
        vwan_name     = "wan-prod",
        vwan_hub_name = "prod"
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
  "vwan-infra" = {
    location            = "East US"
    resource_group_name = "rg-vwan-infra"
    existing            = false
  }
}

vwan_hubs = {
  "infra" = {
    location         = "East US"
    virtual_hub_cidr = "10.2.0.0/24"
  }
  "prod" = {
    location         = "East US"
    virtual_hub_cidr = "10.3.0.0/24"
  }
}

vnets = {
  "workload1-vnet" = {
    cidr            = "10.4.0.0/16"
    private_subnets = ["10.4.1.0/24", "10.4.2.0/24"]
    public_subnets  = ["10.4.3.0/24", "10.4.4.0/24"]
    vwan_name       = "vwan-infra"
    vwan_hub_name   = "infra"
    region          = "East US"
  }
  "workload2-vnet" = {
    resource_group_name = "rg-vnet-workload2-vnet-eastus"
    vwan_name           = "vwan-prod"
    vwan_hub_name       = "prod"
    region              = "East US"
    existing            = true
  }
}