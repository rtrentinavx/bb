variable "aws_ssw_region" {
  type = string
}

variable "region" {
  type = string
}

variable "policies" {
  type = map(object({
    action                   = string
    priority                 = number
    protocol                 = string
    logging                  = bool
    watch                    = bool
    src_smart_groups         = list(string)
    dst_smart_groups         = list(string)
    web_groups               = optional(list(string), [])
    decrypt_policy           = optional(string, "DECRYPT_UNSPECIFIED")
    flow_app_requirement     = optional(string, "APP_UNSPECIFIED")
    exclude_sg_orchestration = optional(bool, true)
    port_ranges              = optional(list(string), [])
  }))
}