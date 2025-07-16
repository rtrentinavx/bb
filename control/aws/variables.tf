variable "aws_ssm_region" {
  type = string
}

variable "region" {
  type = string
}

variable "transits" {
  description = "Map of transit gateway configurations"
  type = map(object({
    account                          = string
    cidr                             = string
    instance_size                    = string
    local_as_number                  = number
    bgp_manual_spoke_advertise_cidrs = optional(string, "")
    fw_amount                        = optional(number, 0)
    fw_instance_size                 = optional(string, "c5.xlarge")
    tgw_name                         = optional(string, "")
    inside_cidr_blocks = map(object({
      connect_peer_1    = string
      ha_connect_peer_1 = string
      connect_peer_2    = string
      ha_connect_peer_2 = string
    }))
  }))
  default = {}
  validation {
    condition     = alltrue([for k, v in var.transits : length(v.tgw_name) > 0])
    error_message = "Each transit must specify a non-empty tgw_name."
  }
}

variable "tgws" {
  description = "Map of AWS Transit Gateway configurations"
  type = map(object({
    amazon_side_asn             = number
    transit_gateway_cidr_blocks = optional(list(string), [])
    create_tgw                  = bool # True to create TGW, false for existing
  }))
  default = {}
}

variable "vpcs" {
  description = "Map of VPC configurations"
  type = map(object({
    cidr            = string
    tgw_key         = optional(string, "")
    private_subnets = list(string)
    public_subnets  = list(string)
  }))
  default = {}
  validation {
    condition     = alltrue([for k, v in var.vpcs : v.tgw_key == "" || contains(keys(var.tgws), v.tgw_key)])
    error_message = "Each VPC's tgw_key, if specified, must match a key in var.tgws."
  }
  validation {
    condition = alltrue([
      for k, v in var.vpcs : alltrue([
        for cidr in concat([v.cidr], v.private_subnets, v.public_subnets) : can(cidrnetmask(cidr))
      ])
    ])
    error_message = "All CIDRs in vpcs must be valid."
  }
}