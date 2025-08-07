locals {
  tgw_name_to_id = { for k, v in data.aws_ec2_transit_gateway.tgw : k => v.id }
  existing_vpcs  = { for k, v in var.vpcs : k => v if try(v.vpc_id, "") != "" }
  new_vpcs       = { for k, v in var.vpcs : k => v if try(v.vpc_id, "") == "" }
  vpc_cidrs = merge(
    { for k, v in data.aws_vpc.existing : k => v.cidr_block },
    { for k, v in module.vpc : k => v.vpc_cidr_block }
  )
  # Filter route CIDRs to exclude only the exact VPC CIDR
  valid_route_cidrs = {
    for vpc_key, vpc_cidr in local.vpc_cidrs :
    vpc_key => [
      for route_cidr in var.route_cidrs :
      route_cidr
      if route_cidr != vpc_cidr
    ]
  }

  # Get route table IDs for both existing and new VPCs
  vpc_private_route_table_ids = merge(
    # For existing VPCs, use the provided route table IDs
    { for k, v in local.existing_vpcs : k => v.private_route_table_ids },
    # For new VPCs, use the route table IDs from the module
    { for k, v in module.vpc : k => v.private_route_table_ids }
  )

  vpc_public_route_table_ids = merge(
    # For existing VPCs, use the provided route table IDs
    { for k, v in local.existing_vpcs : k => v.public_route_table_ids },
    # For new VPCs, use the route table IDs from the module
    { for k, v in module.vpc : k => v.public_route_table_ids }
  )
}

module "vpc" {
  for_each = local.new_vpcs
  source   = "terraform-aws-modules/vpc/aws"
  version  = "~>6.0"

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
  create_igw         = true
  enable_vpn_gateway = false

  providers = {
    aws = aws.target
  }
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
    module.vpc[each.key].private_subnets
  )

  tags = {
    Name = "${each.key}-to-${each.value.tgw_key}"
  }

  depends_on = [module.vpc, data.aws_ec2_transit_gateway.tgw]

  provider = aws.target
}

resource "aws_route" "vpc_private_route" {
  for_each = {
    for pair in flatten([
      for k, v in var.vpcs : [
        for rt_idx, rt_id in local.vpc_private_route_table_ids[k] : [
          for cidr in local.valid_route_cidrs[k] : {
            key            = "${k}.${rt_idx}.${cidr}"
            vpc_key        = k
            route_table_id = rt_id
            cidr           = cidr
          }
        ]
      ] if v.tgw_key != ""
    ]) : pair.key => pair
  }
  provider = aws.target

  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.cidr
  transit_gateway_id     = local.tgw_name_to_id[var.vpcs[each.value.vpc_key].tgw_key]

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.vpc_attachment]
}

resource "aws_route" "vpc_public_route" {
  for_each = {
    for pair in flatten([
      for k, v in var.vpcs : [
        for rt_idx, rt_id in local.vpc_public_route_table_ids[k] : [
          for cidr in local.valid_route_cidrs[k] : {
            key            = "${k}.${rt_idx}.${cidr}"
            vpc_key        = k
            route_table_id = rt_id
            cidr           = cidr
          } if cidr != "0.0.0.0/0"
        ]
      ] if v.tgw_key != ""
    ]) : pair.key => pair
  }
  provider = aws.target

  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.cidr
  transit_gateway_id     = local.tgw_name_to_id[var.vpcs[each.value.vpc_key].tgw_key]

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.vpc_attachment]
}