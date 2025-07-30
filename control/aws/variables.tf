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
    firewall_image                   = optional(string, "")
    firewall_image_version           = optional(string, "")
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

variable "external_devices" {
  description = "Map of external devices to connect to Aviatrix Transit Gateways"
  type = map(object({
    transit_key               = string
    connection_name           = string
    remote_gateway_ip         = string
    bgp_enabled               = bool
    bgp_remote_asn            = optional(string)
    local_tunnel_cidr         = optional(string)
    remote_tunnel_cidr        = optional(string)
    ha_enabled                = bool
    backup_remote_gateway_ip  = optional(string)
    backup_local_tunnel_cidr  = optional(string)
    backup_remote_tunnel_cidr = optional(string)
    enable_ikev2              = optional(bool)
    inspected_by_firenet      = bool
  }))
  default = {}
}