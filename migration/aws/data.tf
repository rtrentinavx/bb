data "aws_vpc" "existing" {
  for_each = local.existing_vpcs

  id = each.value.vpc_id

  provider = aws.target
}

data "aws_subnets" "private" {
  for_each = local.existing_vpcs

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing[each.key].id]
  }

  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }

  provider = aws.target

}

data "aws_availability_zones" "available" {
  state    = "available"
  provider = aws.target
}

data "aws_ec2_transit_gateway" "tgw" {
  for_each = toset([for k, v in var.vpcs : v.tgw_key if v.tgw_key != ""])

  filter {
    name   = "tag:Name"
    values = [each.key]
  }
}