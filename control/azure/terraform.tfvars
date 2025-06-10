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

vwan_hubs = {
  "infra" = {
    location         = "East US"
    virtual_hub_cidr = "10.2.0.0/24"
    subscription_id  = "47ab116c-8c15-4453-b06a-3fecd09ebda9"
  }
  # "hub2" = {
  #   location         = "West US"
  #   virtual_hub_cidr = "10.3.0.0/24"
  # }
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
  # "workload2-vnet" = {
  #   cidr            = "10.5.0.0/16"
  #   private_subnets = ["10.5.1.0/24", "10.5.2.0/24"]
  #   public_subnets  = ["10.5.3.0/24", "10.5.4.0/24"]
  #   vwan_name       = "vwan2"
  #   vwan_hub_name   = "hub2"
  #   region          = "West US"
  # }
}