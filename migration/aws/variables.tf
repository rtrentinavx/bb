variable "region" {
  type = string
}

variable "target_account_id" {
  description = "AWS account ID of the target account where VPCs are created"
  type        = string
}

variable "target_role_name" {
  description = "Name of the IAM role to assume in the target account"
  type        = string
  default     = "CrossAccountVPCRole"
}

variable "route_cidrs" {
  description = "List of CIDR blocks for routing. Defaults to RFC1918 CIDRs and 0.0.0.0/0 if not specified."
  type        = list(string)
  default     = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16", "0.0.0.0/0"]
}

variable "vpcs" {
  description = "Map of VPC configurations, including CIDR, subnets, transit gateway key, and lists of route table IDs."
  type = map(object({
    cidr                    = optional(string)
    private_subnets         = optional(list(string))
    public_subnets          = optional(list(string))
    tgw_key                 = string
    vpc_id                  = optional(string, "")
    private_route_table_ids = optional(list(string), [])
    public_route_table_ids  = optional(list(string), [])
  }))
  default = {}
}