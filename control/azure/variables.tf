variable "aws_ssm_region" {
  type = string
}

variable "region" {
  type = string
}

variable "subscription_id" {
  type = string
}

variable "vwan_configs" {
  description = "Map of Virtual WAN configurations (new or existing)."
  type = map(object({
    resource_group_name = string
    location            = optional(string) # Required for new vWANs
    existing            = bool             # True for existing vWANs, false for new
  }))
  default = {}
}

variable "vnets" {
  description = "Map of VNET configurations for new or pre-existing VNETs to connect to Virtual WAN hubs."
  type = map(object({
    resource_group_name = optional(string)
    existing            = optional(bool, false)
    cidr                = optional(string)
    private_subnets     = optional(list(string), [])
    public_subnets      = optional(list(string), [])
    vwan_hub_name       = string
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

variable "transits" {
  description = "Map of transit gateway configurations for Aviatrix."
  type = map(object({
    account          = string
    cidr             = string
    instance_size    = string
    local_as_number  = number
    fw_amount        = optional(number, 0)
    fw_instance_size = optional(string)
    vwan_connections = list(object({
      vwan_name     = string
      vwan_hub_name = string
    }))
  }))
  default = {}
}

variable "spokes" {
  description = "Map of spoke gateway configurations for Aviatrix."
  type = map(object({
    account         = string
    cidr            = string
    instance_size   = string
    local_as_number = number
    vwan_connections = list(object({
      vwan_name     = string
      vwan_hub_name = string
    }))
  }))
  default = {}
}

variable "vwan_hubs" {
  description = "Map of Virtual WAN hub configurations."
  type = map(object({
    virtual_hub_cidr                       = string
    virtual_router_auto_scale_min_capacity = optional(number)
  }))
  default = {}
}