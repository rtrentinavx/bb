locals {
  tgw_name_to_id = { for k, v in data.aws_ec2_transit_gateway.tgw : k => v.id }

  rfc1918_cidrs = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}

module "vpc" {
  for_each = var.vpcs
  source   = "terraform-aws-modules/vpc/aws"
  version  = "5.8.1"

  name = each.key
  cidr = each.value.cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, max(length(each.value.private_subnets), length(each.value.public_subnets)))
  private_subnets = each.value.private_subnets
  public_subnets  = each.value.public_subnets

  private_subnet_names = [for idx, az in slice(data.aws_availability_zones.available.names, 0, length(each.value.private_subnets)) : "${each.key}-${az}-private-${idx + 1}"]
  public_subnet_names  = [for idx, az in slice(data.aws_availability_zones.available.names, 0, length(each.value.public_subnets)) : "${each.key}-${az}-public-${idx + 1}"]

  private_route_table_tags = {
    Name = "${each.key}-private-rt"
  }
  public_route_table_tags = {
    Name = "${each.key}-public-rt"
  }

  private_subnet_tags = {
    for idx, az in slice(data.aws_availability_zones.available.names, 0, length(each.value.private_subnets)) :
    tostring(idx) => "${each.key}-${az}-private-${idx + 1}"
  }
  public_subnet_tags = {
    for idx, az in slice(data.aws_availability_zones.available.names, 0, length(each.value.public_subnets)) :
    tostring(idx) => "${each.key}-${az}-public-${idx + 1}"
  }

  enable_nat_gateway = false
  single_nat_gateway = true
  enable_vpn_gateway = false

}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_attachment" {
  for_each           = { for k, v in var.vpcs : k => v if v.tgw_key != "" }
  subnet_ids         = slice(module.vpc[each.key].private_subnets, 0, min(1, length(module.vpc[each.key].private_subnets)))
  transit_gateway_id = local.tgw_name_to_id[each.value.tgw_key]
  vpc_id             = module.vpc[each.key].vpc_id

  tags = {
    Name = "${each.key}-to-${each.value.tgw_key}"
  }

  depends_on = [module.vpc, data.aws_ec2_transit_gateway.tgw]
}

resource "aws_route" "vpc_private_route" {
  for_each = {
    for pair in flatten([
      for k, v in var.vpcs : [
        for cidr in concat(local.rfc1918_cidrs, ["0.0.0.0/0"]) : {
          key     = "${k}.${cidr}"
          vpc_key = k
          cidr    = cidr
        }
      ] if v.tgw_key != ""
    ]) : pair.key => pair
  }
  route_table_id         = module.vpc[each.value.vpc_key].private_route_table_ids[0]
  destination_cidr_block = each.value.cidr
  transit_gateway_id     = local.tgw_name_to_id[var.vpcs[each.value.vpc_key].tgw_key]

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.vpc_attachment]
}

resource "aws_route" "vpc_public_route" {
  for_each = {
    for pair in flatten([
      for k, v in var.vpcs : [
        for cidr in local.rfc1918_cidrs : {
          key     = "${k}.${cidr}"
          vpc_key = k
          cidr    = cidr
        }
      ] if v.tgw_key != ""
    ]) : pair.key => pair
  }
  route_table_id         = module.vpc[each.value.vpc_key].public_route_table_ids[0]
  destination_cidr_block = each.value.cidr
  transit_gateway_id     = local.tgw_name_to_id[var.vpcs[each.value.vpc_key].tgw_key]

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.vpc_attachment]
}