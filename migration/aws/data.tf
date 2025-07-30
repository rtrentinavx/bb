data "aws_ec2_transit_gateway" "tgw" {
  for_each = toset(distinct([for vpc in var.vpcs : vpc.tgw_key]))

  filter {
    name   = "tag:Name"
    values = [each.key]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}