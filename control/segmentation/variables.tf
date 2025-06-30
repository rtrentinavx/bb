variable "connection_policy" {
  type = list(object({
    source = string
    target = string
  }))
  default = []
}
variable "destroy_url" {
  type        = string
  description = "Dummy URL used by terracurl during destroy operations."
  default     = "https://checkip.amazonaws.com"
}