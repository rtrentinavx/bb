locals {
  tgw_name_to_id = { for k, v in data.aws_ec2_transit_gateway.tgw : k => v.id }

  existing_vpcs = {
    for k, v in var.vpcs : k => v
    if try(v.vpc_id, "") != ""
  }

  new_vpcs = {
    for k, v in var.vpcs : k => v
    if try(v.vpc_id, "") == ""
  }

}

module "vpc" {
  for_each = local.new_vpcs
  source   = "terraform-aws-modules/vpc/aws"
  version  = "~>5.0"

  name = each.key
  cidr = each.value.cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, max(length(each.value.private_subnets), length(each.value.public_subnets)))
  private_subnets = each.value.private_subnets
  public_subnets  = each.value.public_subnets

  private_subnet_names = [for idx, az in slice(data.aws_availability_zones.available.names, 0, length(each.value.private_subnets)) : "${each.key}-${az}-private-${idx + 1}"]
  public_subnet_names  = [for idx, az in slice(data.aws_availability_zones.available.names, 0, length(each.value.public_subnets)) : "${each.key}-${az}-public-${idx + 1}"]

  private_route_table_tags = {
    Name = "${each.key}-private-rt"
    Type = "private"
  }
  public_route_table_tags = {
    Name = "${each.key}-public-rt"
    Type = "public"
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
  for_each = var.vpcs

  transit_gateway_id = local.tgw_name_to_id[each.value.tgw_key]
  vpc_id = try(
    data.aws_vpc.existing[each.key].id,
    module.vpc[each.key].vpc_id
  )
  subnet_ids = try(
    data.aws_subnets.private[each.key].ids,
    slice(
      module.vpc[each.key].private_subnets,
      0,
      min(1, length(try(module.vpc[each.key].private_subnets, [])))
    )
  )

  tags = {
    Name = "${each.key}-to-${each.value.tgw_key}"
  }

  depends_on = [module.vpc, data.aws_ec2_transit_gateway.tgw]
}

resource "aws_route" "vpc_private_route" {
  for_each = {
    for pair in flatten([
      for k, v in var.vpcs : [
        for rt_idx, rt_id in v.private_route_table_ids : [
          for cidr in var.route_cidrs : {
            key            = "${k}.${rt_idx}.${cidr}"
            vpc_key        = k
            route_table_id = rt_id
            cidr           = cidr
          }
        ]
      ] if v.tgw_key != ""
    ]) : pair.key => pair
  }
  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.cidr
  transit_gateway_id     = local.tgw_name_to_id[var.vpcs[each.value.vpc_key].tgw_key]

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.vpc_attachment]
}


resource "aws_route" "vpc_public_route" {
  for_each = {
    for pair in flatten([
      for k, v in var.vpcs : [
        for rt_idx, rt_id in v.public_route_table_ids : [
          for cidr in var.route_cidrs : {
            key            = "${k}.${rt_idx}.${cidr}"
            vpc_key        = k
            route_table_id = rt_id
            cidr           = cidr
          }
        ]
      ] if v.tgw_key != ""
    ]) : pair.key => pair
  }
  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.cidr
  transit_gateway_id     = local.tgw_name_to_id[var.vpcs[each.value.vpc_key].tgw_key]

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.vpc_attachment]
}