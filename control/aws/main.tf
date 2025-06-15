locals {
  stripped_names = {
    for k, v in var.transits : k => (
      length(regexall("^(.+)-vpc$", k)) > 0 ?
      regex("^(.+)-vpc$", k)[0] :
      k
    )
  }
  tgw_name_to_info = { for k, v in var.tgws : k => v }
  tgw_name_to_id = merge(
    { for k, v in aws_ec2_transit_gateway.tgw : k => v.id },
    { for k, v in data.aws_ec2_transit_gateway.tgw : k => v.id }
  )
  rfc1918_cidrs = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  transit_keys  = [for k, v in var.transits : k if v.tgw_name != ""]

  tgw_names_per_transit = {
    for k, v in var.transits : k => v.tgw_name != "" ? (
      can(split(",", v.tgw_name)) ? split(",", v.tgw_name) : (
        can(tolist(v.tgw_name)) ? tolist(v.tgw_name) : [v.tgw_name]
      )
    ) : []
  }

  transit_tgw_pairs = flatten([
    for transit_key, tgw_names in local.tgw_names_per_transit : [
      for tgw_name in tgw_names : {
        transit_key = transit_key
        tgw_name    = tgw_name
        pair_key    = "${transit_key}.${tgw_name}"
      }
    ]
  ])

  transit_tgw_map = { for pair in local.transit_tgw_pairs : pair.pair_key => pair }

  tgw_connect_ip = {
    for pair in local.transit_tgw_pairs : pair.pair_key => {
      connect_peer_1    = cidrhost(element(local.tgw_name_to_info[pair.tgw_name].transit_gateway_cidr_blocks, 0), 1 + index(local.transit_keys, pair.transit_key) * 4)
      ha_connect_peer_1 = cidrhost(element(local.tgw_name_to_info[pair.tgw_name].transit_gateway_cidr_blocks, 0), 2 + index(local.transit_keys, pair.transit_key) * 4)
      connect_peer_2    = cidrhost(element(local.tgw_name_to_info[pair.tgw_name].transit_gateway_cidr_blocks, 0), 3 + index(local.transit_keys, pair.transit_key) * 4)
      ha_connect_peer_2 = cidrhost(element(local.tgw_name_to_info[pair.tgw_name].transit_gateway_cidr_blocks, 0), 4 + index(local.transit_keys, pair.transit_key) * 4)
    }
  }

  all_tgw_names = toset([for pair in local.transit_tgw_pairs : pair.tgw_name])

}

module "mc-transit" {
  for_each                         = var.transits
  source                           = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version                          = "2.6.0"
  account                          = each.value.account
  bgp_ecmp                         = true
  cloud                            = "aws"
  cidr                             = each.value.cidr
  connected_transit                = true
  enable_egress_transit_firenet    = false
  enable_encrypt_volume            = true
  enable_firenet                   = false
  enable_s2c_rx_balancing          = true
  enable_transit_firenet           = each.value.fw_amount > 0 ? true : false
  instance_size                    = each.value.instance_size
  insane_mode                      = true
  local_as_number                  = each.value.local_as_number
  name                             = each.key
  gw_name                          = local.stripped_names[each.key]
  region                           = each.value.region
  bgp_manual_spoke_advertise_cidrs = each.value.bgp_manual_spoke_advertise_cidrs
  enable_preserve_as_path          = true
  enable_segmentation              = true
  enable_advertise_transit_cidr    = true
}

module "mc-firenet" {
  for_each               = { for k, v in var.transits : k => v if v.fw_amount > 0 }
  source                 = "terraform-aviatrix-modules/mc-firenet/aviatrix"
  version                = "1.6.0"
  transit_module         = module.mc-transit[each.key]
  firewall_image         = "Palo Alto Networks VM-Series Next-Generation Firewall (BYOL)"
  firewall_image_version = "10.2.14"
  instance_size          = each.value.fw_instance_size
  egress_enabled         = true
  fw_amount              = each.value.fw_amount
}

resource "aws_ec2_transit_gateway" "tgw" {
  for_each                    = { for k, v in var.tgws : k => v if v.create_tgw }
  amazon_side_asn             = each.value.amazon_side_asn
  transit_gateway_cidr_blocks = each.value.transit_gateway_cidr_blocks
  tags = {
    Name = each.key
  }
}

resource "aws_route" "route" {
  for_each = {
    for pair in flatten([
      for k, v in var.transits : [
        for tgw_name in local.tgw_names_per_transit[k] : {
          key         = "${k}.${tgw_name}"
          transit_key = k
          tgw_name    = tgw_name
        }
      ] if v.tgw_name != ""
    ]) : pair.key => pair
  }
  route_table_id         = data.aws_route_table.route_table[each.value.transit_key].id
  destination_cidr_block = element(local.tgw_name_to_info[each.value.tgw_name].transit_gateway_cidr_blocks, 0)
  transit_gateway_id     = local.tgw_name_to_id[each.value.tgw_name]
}

resource "aws_ec2_transit_gateway_vpc_attachment" "attachment" {
  for_each           = local.transit_tgw_map
  subnet_ids         = [data.aws_subnet.gw_subnet[each.value.transit_key].id, data.aws_subnet.hagw_subnet[each.value.transit_key].id]
  transit_gateway_id = local.tgw_name_to_id[each.value.tgw_name]
  vpc_id             = module.mc-transit[each.value.transit_key].vpc.vpc_id

  tags = {
    Name = "${each.value.transit_key}-to-${each.value.tgw_name}"
  }
}

resource "aws_ec2_transit_gateway_connect" "connect" {
  for_each                = local.transit_tgw_map
  transport_attachment_id = aws_ec2_transit_gateway_vpc_attachment.attachment[each.key].id
  transit_gateway_id      = local.tgw_name_to_id[each.value.tgw_name]
}

resource "aws_ec2_transit_gateway_connect_peer" "connect_peer-1" {
  for_each                      = local.transit_tgw_map
  bgp_asn                       = module.mc-transit[each.value.transit_key].transit_gateway.local_as_number
  inside_cidr_blocks            = [var.transits[each.value.transit_key].inside_cidr_blocks[each.value.tgw_name].connect_peer_1]
  peer_address                  = module.mc-transit[each.value.transit_key].transit_gateway.private_ip
  transit_gateway_address       = local.tgw_connect_ip[each.key].connect_peer_1
  transit_gateway_attachment_id = aws_ec2_transit_gateway_connect.connect[each.key].id
}

resource "aws_ec2_transit_gateway_connect_peer" "ha_connect_peer-1" {
  for_each                      = local.transit_tgw_map
  bgp_asn                       = module.mc-transit[each.value.transit_key].transit_gateway.local_as_number
  inside_cidr_blocks            = [var.transits[each.value.transit_key].inside_cidr_blocks[each.value.tgw_name].ha_connect_peer_1]
  peer_address                  = module.mc-transit[each.value.transit_key].transit_gateway.ha_private_ip
  transit_gateway_address       = local.tgw_connect_ip[each.key].ha_connect_peer_1
  transit_gateway_attachment_id = aws_ec2_transit_gateway_connect.connect[each.key].id
}

resource "aws_ec2_transit_gateway_connect_peer" "connect_peer-2" {
  for_each                      = local.transit_tgw_map
  bgp_asn                       = module.mc-transit[each.value.transit_key].transit_gateway.local_as_number
  inside_cidr_blocks            = [var.transits[each.value.transit_key].inside_cidr_blocks[each.value.tgw_name].connect_peer_2]
  peer_address                  = module.mc-transit[each.value.transit_key].transit_gateway.private_ip
  transit_gateway_address       = local.tgw_connect_ip[each.key].connect_peer_2
  transit_gateway_attachment_id = aws_ec2_transit_gateway_connect.connect[each.key].id
}

resource "aws_ec2_transit_gateway_connect_peer" "ha_connect_peer-2" {
  for_each                      = local.transit_tgw_map
  bgp_asn                       = module.mc-transit[each.value.transit_key].transit_gateway.local_as_number
  inside_cidr_blocks            = [var.transits[each.value.transit_key].inside_cidr_blocks[each.value.tgw_name].ha_connect_peer_2]
  peer_address                  = module.mc-transit[each.value.transit_key].transit_gateway.ha_private_ip
  transit_gateway_address       = local.tgw_connect_ip[each.key].ha_connect_peer_2
  transit_gateway_attachment_id = aws_ec2_transit_gateway_connect.connect[each.key].id
}

resource "aviatrix_transit_external_device_conn" "external-1" {
  for_each                = local.transit_tgw_map
  vpc_id                  = module.mc-transit[each.value.transit_key].vpc.vpc_id
  connection_name         = "external-${local.tgw_name_to_id[each.value.tgw_name]}-1-${each.value.transit_key}"
  gw_name                 = module.mc-transit[each.value.transit_key].transit_gateway.gw_name
  remote_gateway_ip       = "${local.tgw_connect_ip[each.key].connect_peer_1},${local.tgw_connect_ip[each.key].ha_connect_peer_1}"
  direct_connect          = true
  bgp_local_as_num        = module.mc-transit[each.value.transit_key].transit_gateway.local_as_number
  bgp_remote_as_num       = local.tgw_name_to_info[each.value.tgw_name].amazon_side_asn
  tunnel_protocol         = "GRE"
  ha_enabled              = false
  local_tunnel_cidr       = "${cidrhost(var.transits[each.value.transit_key].inside_cidr_blocks[each.value.tgw_name].connect_peer_1, 1)}/29,${cidrhost(var.transits[each.value.transit_key].inside_cidr_blocks[each.value.tgw_name].ha_connect_peer_1, 1)}/29"
  remote_tunnel_cidr      = "${cidrhost(var.transits[each.value.transit_key].inside_cidr_blocks[each.value.tgw_name].connect_peer_1, 2)}/29,${cidrhost(var.transits[each.value.transit_key].inside_cidr_blocks[each.value.tgw_name].ha_connect_peer_1, 2)}/29"
  custom_algorithms       = false
  phase1_local_identifier = null
  enable_jumbo_frame      = true
}

resource "aviatrix_transit_external_device_conn" "external-2" {
  for_each                = local.transit_tgw_map
  vpc_id                  = module.mc-transit[each.value.transit_key].vpc.vpc_id
  connection_name         = "external-${local.tgw_name_to_id[each.value.tgw_name]}-2-${each.value.transit_key}"
  gw_name                 = module.mc-transit[each.value.transit_key].transit_gateway.gw_name
  remote_gateway_ip       = "${local.tgw_connect_ip[each.key].connect_peer_2},${local.tgw_connect_ip[each.key].ha_connect_peer_2}"
  direct_connect          = true
  bgp_local_as_num        = module.mc-transit[each.value.transit_key].transit_gateway.local_as_number
  bgp_remote_as_num       = local.tgw_name_to_info[each.value.tgw_name].amazon_side_asn
  tunnel_protocol         = "GRE"
  ha_enabled              = false
  local_tunnel_cidr       = "${cidrhost(var.transits[each.value.transit_key].inside_cidr_blocks[each.value.tgw_name].connect_peer_2, 1)}/29,${cidrhost(var.transits[each.value.transit_key].inside_cidr_blocks[each.value.tgw_name].ha_connect_peer_2, 1)}/29"
  remote_tunnel_cidr      = "${cidrhost(var.transits[each.value.transit_key].inside_cidr_blocks[each.value.tgw_name].connect_peer_2, 2)}/29,${cidrhost(var.transits[each.value.transit_key].inside_cidr_blocks[each.value.tgw_name].ha_connect_peer_2, 2)}/29"
  custom_algorithms       = false
  phase1_local_identifier = null
  enable_jumbo_frame      = true
}

module "vpc" {
  for_each = var.vpcs
  source   = "terraform-aws-modules/vpc/aws"
  version  = "5.8.1"

  name = each.key
  cidr = each.value.cidr

  azs             = slice(data.aws_availability_zones.available[each.key].names, 0, max(length(each.value.private_subnets), length(each.value.public_subnets)))
  private_subnets = each.value.private_subnets
  public_subnets  = each.value.public_subnets

  private_subnet_names = [for idx, az in slice(data.aws_availability_zones.available[each.key].names, 0, length(each.value.private_subnets)) : "${each.key}-${az}-private-${idx + 1}"]
  public_subnet_names  = [for idx, az in slice(data.aws_availability_zones.available[each.key].names, 0, length(each.value.public_subnets)) : "${each.key}-${az}-public-${idx + 1}"]

  private_route_table_tags = {
    Name = "${each.key}-private-rt"
  }
  public_route_table_tags = {
    Name = "${each.key}-public-rt"
  }

  private_subnet_tags = {
    for idx, az in slice(data.aws_availability_zones.available[each.key].names, 0, length(each.value.private_subnets)) :
    tostring(idx) => "${each.key}-${az}-private-${idx + 1}"
  }
  public_subnet_tags = {
    for idx, az in slice(data.aws_availability_zones.available[each.key].names, 0, length(each.value.public_subnets)) :
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

  depends_on = [module.vpc, aws_ec2_transit_gateway.tgw, data.aws_ec2_transit_gateway.tgw]
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

# resource "aviatrix_segmentation_network_domain" "segmentation_network_domain" {
#   for_each    = local.transit_tgw_map
#   domain_name = each.value.tgw_name
# }

# resource "aviatrix_segmentation_network_domain_association" "external-1-segmentation_network_domain_association" {
#   for_each            = local.transit_tgw_map
#   network_domain_name = each.value.tgw_name
#   attachment_name     = aviatrix_transit_external_device_conn.external-1[each.key].connection_name
#   depends_on          = [aviatrix_segmentation_network_domain.segmentation_network_domain]
# }

# resource "aviatrix_segmentation_network_domain_association" "external-2-segmentation_network_domain_association" {
#   for_each            = local.transit_tgw_map
#   network_domain_name = each.value.tgw_name
#   attachment_name     = aviatrix_transit_external_device_conn.external-2[each.key].connection_name
#   depends_on          = [aviatrix_segmentation_network_domain.segmentation_network_domain]
# }

# resource "aviatrix_segmentation_network_domain_connection_policy" "to_infra" {
#   for_each = { for name in local.all_tgw_names : name => name if name != "infra" }

#   domain_name_1 = each.value
#   domain_name_2 = "infra"

#   depends_on = [aviatrix_segmentation_network_domain.segmentation_network_domain]
# }