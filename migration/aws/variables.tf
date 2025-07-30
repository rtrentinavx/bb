variable "aws_ssm_region" {
  type = string
}

variable "region" {
  type = string
}

variable "vpcs" {
  description = "Map of VPC configurations"
  type = map(object({
    cidr            = string
    tgw_key         = string
    private_subnets = list(string)
    public_subnets  = list(string)
  }))
  default = {}

  validation {
    condition     = alltrue([for v in var.vpcs : v.tgw_key != ""])
    error_message = "Each VPC's tgw_key must not be empty."
  }

  validation {
    condition = alltrue([
      for v in var.vpcs : alltrue([
        for cidr in concat([v.cidr], v.private_subnets, v.public_subnets) : can(cidrnetmask(cidr))
      ])
    ])
    error_message = "All CIDRs in vpcs must be valid."
  }
}
