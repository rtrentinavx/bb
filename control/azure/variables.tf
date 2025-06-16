variable "subscription_id" {
  type = string
}
variable "vwan_hubs" {
  type = map(object({
    location                               = string
    virtual_hub_cidr                       = string
    subscription_id                        = optional(string)
    virtual_router_auto_scale_min_capacity = optional(string)
  }))
  default = {
  }
}

variable "transits" {
  type = map(object({
    cidr             = string
    region           = string
    instance_size    = string
    account          = string
    local_as_number  = number
    fw_amount        = optional(number)
    fw_instance_size = optional(string)
    vwan_connections = list(object({
      vwan_name     = string
      vwan_hub_name = string
    }))
  }))
  default = {
  }
}

variable "spokes" {
  type = map(object({
    cidr            = string
    region          = string
    instance_size   = string
    account         = string
    local_as_number = number
    vwan_connections = list(object({
      vwan_name     = string
      vwan_hub_name = string
    }))
  }))
  default = {
  }

}

variable "vnets" {
  description = "Map of VNET configurations for new or pre-existing VNETs to connect to Virtual WAN hubs."
  type = map(object({
    resource_group_name = optional(string)           # Resource group name for pre-existing VNETs
    existing            = optional(bool, false)      # Flag to indicate pre-existing VNET
    cidr                = optional(string)           # CIDR for new VNETs (required if existing = false)
    private_subnets     = optional(list(string), []) # Private subnet CIDRs for new VNETs
    public_subnets      = optional(list(string), []) # Public subnet CIDRs for new VNETs
    region              = string                     # Azure region
    vwan_name           = string                     # Virtual WAN name for hub connection
    vwan_hub_name       = string                     # Virtual WAN hub name for connection
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.vnets :
      v.existing == false ? v.cidr != null : true
    ])
    error_message = "The 'cidr' attribute is required for new VNETs (when existing = false or not set)."
  }
}