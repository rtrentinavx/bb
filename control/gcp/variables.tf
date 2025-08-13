variable "aws_ssm_region" {
  type = string 
}

variable "hub_project_id" {
  type        = string
  description = "GCP project ID for NCC hubs"
  validation {
    condition     = length(var.hub_project_id) > 0
    error_message = "hub_project_id must be non-empty."
  }
}

variable "transits" {
  type = list(object({
    gw_name             = string
    project_id          = string
    region              = string
    name                = string
    vpc_cidr            = string
    gw_size             = string
    access_account_name = string
    cloud_router_asn    = number
    aviatrix_gw_asn     = number
    bgp_lan_subnets = object({
      interconnect = optional(string)
      infra        = optional(string)
      non-prod     = optional(string)
      prod         = optional(string)
    })
  }))
  validation {
    condition = alltrue([
      for t in var.transits :
      t.bgp_lan_subnets.interconnect != "" ||
      t.bgp_lan_subnets.infra != "" ||
      t.bgp_lan_subnets.non-prod != "" ||
      t.bgp_lan_subnets.prod != ""
    ])
    error_message = "At least one BGP LAN subnet must be provided for each transit."
  }
  validation {
    condition = alltrue([
      for t in var.transits :
      alltrue([
        for s in [
          t.bgp_lan_subnets.interconnect,
          t.bgp_lan_subnets.infra,
          t.bgp_lan_subnets.non-prod,
          t.bgp_lan_subnets.prod
        ] : s == "" || can(cidrhost(s, 1))
      ])
    ])
    error_message = "All non-empty BGP LAN subnets must be valid CIDR ranges."
  }
  validation {
    condition     = alltrue([for t in var.transits : length(t.gw_name) <= 30])
    error_message = "gw_name must be 30 characters or less to ensure VPC/subnet names fit within GCP limits."
  }
  validation {
    condition     = alltrue([for t in var.transits : length(t.access_account_name) > 0])
    error_message = "access_account_name must be provided for each transit."
  }
  validation {
    condition = alltrue([
      for t in var.transits :
      contains(["n2-highcpu-8", "n1-standard-8", "c2-standard-8"], t.gw_size)
    ])
    error_message = "gw_size must be an instance type supporting at least 5 network interfaces (e.g., n2-highcpu-8, n1-standard-8, c2-standard-8)."
  }
  validation {
    condition = alltrue([
      for t in var.transits :
      t.cloud_router_asn >= 64512 && t.cloud_router_asn <= 65534
    ])
    error_message = "cloud_router_asn must be a private ASN between 64512 and 65534."
  }
  validation {
    condition = alltrue([
      for t in var.transits :
      t.aviatrix_gw_asn >= 64512 && t.aviatrix_gw_asn <= 65534 && t.aviatrix_gw_asn != t.cloud_router_asn
    ])
    error_message = "aviatrix_gw_asn must be a private ASN between 64512 and 65534 and must not match cloud_router_asn."
  }
}

variable "spokes" {
  type = list(object({
    vpc_name   = string
    project_id = string
    ncc_hub    = string
  }))
  validation {
    condition     = length(var.spokes) > 0
    error_message = "At least one spoke must be defined."
  }
  validation {
    condition = alltrue([
      for s in var.spokes :
      contains(["interconnect", "infra", "non-prod", "prod"], s.ncc_hub)
    ])
    error_message = "ncc_hub must be one of: interconnect, infra, non-prod, prod."
  }
  validation {
    condition = alltrue([
      for s in var.spokes :
      length(s.vpc_name) > 0 && length(regexall("^[a-z][-a-z0-9]*[a-z0-9]$", s.vpc_name)) > 0
    ])
    error_message = "vpc_name must start with a lowercase letter, contain only lowercase letters, numbers, or hyphens, and end with a letter or number."
  }
  validation {
    condition     = length(var.spokes) == length(distinct([for s in var.spokes : "${s.vpc_name}-${s.ncc_hub}"]))
    error_message = "Each vpc_name must be attached to a given ncc_hub only once."
  }
}

variable "ncc_hubs" {
  description = "List of NCC hubs to create, including a flag to control creation"
  type = list(object({
    name   = string
    create = bool
  }))
  default = [

  ]
}