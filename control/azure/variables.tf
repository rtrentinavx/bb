variable "vwan_hubs" {
  type = map(object({
    location         = string
    virtual_hub_cidr = string
    subscription_id  = string
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

variable "vnets" {
  type = map(object({
    vwan_name       = string
    vwan_hub_name   = string
    cidr            = string
    region          = string
    private_subnets = list(string)
    public_subnets  = list(string)
  }))
  default = {
  }
}