variable "aws_ssw_region" {
  type = string
}

variable "smarties" {
  description = "Map of smart groups to create"
  type = map(object({
    cidr = optional(string)
    tags = optional(map(string))
  }))
  default = {}
}

variable "policies" {
  description = "Map of distributed firewalling policies"
  type = map(object({
    action           = string
    priority         = number
    protocol         = string
    logging          = bool
    watch            = bool
    src_smart_groups = list(string)
    dst_smart_groups = list(string)
    port_ranges      = optional(list(string), [])
  }))
  default = {}
}