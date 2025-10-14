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

  transit_keys = [for k, v in var.transits : k if v.tgw_name != ""]

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

  firenet_transit_keys = [
    for k, v in var.transits : k if v.fw_amount > 0
  ]

  inspection_policies = flatten([
    for transit_key in local.firenet_transit_keys : [
      for tgw_name in local.tgw_names_per_transit[transit_key] : [
        {
          transit_key     = transit_key
          tgw_name        = tgw_name
          connection_name = "external-${tgw_name}-${local.tgw_name_to_id[tgw_name]}-1-${transit_key}"
          pair_key        = "${transit_key}.${tgw_name}.external-1"
        },
        {
          transit_key     = transit_key
          tgw_name        = tgw_name
          connection_name = "external-${tgw_name}-${local.tgw_name_to_id[tgw_name]}-2-${transit_key}"
          pair_key        = "${transit_key}.${tgw_name}.external-2"
        }
      ]
    ]
  ])

  external_device_pairs = {
    for k, v in var.external_devices : k => {
      transit_key               = v.transit_key
      connection_name           = v.connection_name
      pair_key                  = "${v.transit_key}.${v.connection_name}"
      remote_gateway_ip         = v.remote_gateway_ip
      bgp_enabled               = v.bgp_enabled
      bgp_remote_asn            = v.bgp_enabled ? v.bgp_remote_asn : null
      backup_bgp_remote_as_num  = v.ha_enabled ? v.bgp_remote_asn : null
      local_tunnel_cidr         = v.local_tunnel_cidr
      remote_tunnel_cidr        = v.remote_tunnel_cidr
      ha_enabled                = v.ha_enabled
      backup_remote_gateway_ip  = v.ha_enabled ? v.backup_remote_gateway_ip : null
      backup_local_tunnel_cidr  = v.ha_enabled ? v.backup_local_tunnel_cidr : null
      backup_remote_tunnel_cidr = v.ha_enabled ? v.backup_remote_tunnel_cidr : null
      enable_ikev2              = v.enable_ikev2
      inspected_by_firenet      = v.inspected_by_firenet
    }
  }

  external_inspection_policies = [
    for k, v in local.external_device_pairs : {
      transit_key     = v.transit_key
      connection_name = v.connection_name
      pair_key        = v.pair_key
    } if v.inspected_by_firenet && lookup(var.transits[v.transit_key], "fw_amount", 0) > 0
  ]

  tgw_account_pairs = flatten([
    for tgw_name, tgw in var.tgws : [
      for account_id in tgw.account_ids : {
        tgw_name   = tgw_name
        account_id = account_id
        key        = "${tgw_name}.${account_id}"
      }
    ] if tgw.create_tgw && length(tgw.account_ids) > 0
  ])
  tgw_account_pairs_map = { for pair in local.tgw_account_pairs : pair.key => pair }

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
  region                           = var.region
  bgp_manual_spoke_advertise_cidrs = each.value.bgp_manual_spoke_advertise_cidrs
  enable_preserve_as_path          = true
  enable_segmentation              = true
  enable_advertise_transit_cidr    = true
  enable_multi_tier_transit        = true
}

module "mc-firenet" {
  for_each                = { for k, v in var.transits : k => v if v.fw_amount > 0 }
  source                  = "terraform-aviatrix-modules/mc-firenet/aviatrix"
  version                 = "1.6.0"
  transit_module          = module.mc-transit[each.key]
  firewall_image          = each.value.firewall_image
  firewall_image_version  = each.value.firewall_image_version
  instance_size           = each.value.fw_instance_size
  egress_enabled          = true
  fw_amount               = each.value.fw_amount
  bootstrap_bucket_name_1 = each.value.bootstrap_bucket_name_1
}

resource "aws_ec2_transit_gateway" "tgw" {
  for_each                       = { for k, v in var.tgws : k => v if v.create_tgw }
  amazon_side_asn                = each.value.amazon_side_asn
  auto_accept_shared_attachments = "enable" # Enable auto-accept for cross-account attachments
  transit_gateway_cidr_blocks    = each.value.transit_gateway_cidr_blocks
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
  connection_name         = "external-${each.value.tgw_name}-${local.tgw_name_to_id[each.value.tgw_name]}-1-${each.value.transit_key}"
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
  connection_name         = "external-${each.value.tgw_name}-${local.tgw_name_to_id[each.value.tgw_name]}-2-${each.value.transit_key}"
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

resource "aviatrix_transit_firenet_policy" "inspection_policies" {
  for_each = {
    for policy in concat(local.inspection_policies, local.external_inspection_policies) : policy.pair_key => policy
  }

  transit_firenet_gateway_name = module.mc-transit[each.value.transit_key].transit_gateway.gw_name
  inspected_resource_name      = "SITE2CLOUD:${each.value.connection_name}"

  depends_on = [
    module.mc-firenet,
    aviatrix_transit_external_device_conn.external-1,
    aviatrix_transit_external_device_conn.external-2,
    aviatrix_transit_external_device_conn.external_device
  ]
}

resource "aviatrix_transit_external_device_conn" "external_device" {
  for_each                  = local.external_device_pairs
  vpc_id                    = module.mc-transit[each.value.transit_key].vpc.vpc_id
  connection_name           = each.value.connection_name
  gw_name                   = module.mc-transit[each.value.transit_key].transit_gateway.gw_name
  remote_gateway_ip         = each.value.remote_gateway_ip
  backup_remote_gateway_ip  = each.value.ha_enabled ? each.value.backup_remote_gateway_ip : null
  backup_bgp_remote_as_num  = each.value.ha_enabled ? each.value.bgp_remote_asn : null
  connection_type           = each.value.bgp_enabled ? "bgp" : "static"
  bgp_local_as_num          = each.value.bgp_enabled ? module.mc-transit[each.value.transit_key].transit_gateway.local_as_number : null
  bgp_remote_as_num         = each.value.bgp_enabled ? each.value.bgp_remote_asn : null
  tunnel_protocol           = "IPsec"
  direct_connect            = false
  ha_enabled                = each.value.ha_enabled
  local_tunnel_cidr         = each.value.local_tunnel_cidr
  remote_tunnel_cidr        = each.value.remote_tunnel_cidr
  backup_local_tunnel_cidr  = each.value.ha_enabled ? each.value.backup_local_tunnel_cidr : null
  backup_remote_tunnel_cidr = each.value.ha_enabled ? each.value.backup_remote_tunnel_cidr : null
  enable_ikev2              = each.value.enable_ikev2 != null ? each.value.enable_ikev2 : false
  custom_algorithms         = false
  phase1_local_identifier   = null

  depends_on = [module.mc-transit]
}

resource "aws_ram_resource_share" "tgw_share" {
  for_each = { for k, v in var.tgws : k => v if v.create_tgw && (length(v.account_ids) > 0) }

  name                      = "tgw-share-${each.key}"
  allow_external_principals = length(each.value.account_ids) > 0 ? true : false

  tags = {
    Name = "tgw-share-${each.key}"
  }
}

resource "aws_ram_resource_association" "tgw_association" {
  for_each = { for k, v in var.tgws : k => v if v.create_tgw && (length(v.account_ids) > 0) }

  resource_arn       = aws_ec2_transit_gateway.tgw[each.key].arn
  resource_share_arn = aws_ram_resource_share.tgw_share[each.key].arn
}

resource "aws_ram_principal_association" "tgw_principal_account" {
  for_each           = local.tgw_account_pairs_map
  resource_share_arn = aws_ram_resource_share.tgw_share[each.value.tgw_name].arn
  principal          = each.value.account_id
}
