locals {
  all_gateways_by_cloud_type = {
    for gw in data.aviatrix_transit_gateways.all_transit_gws.gateway_list :
    gw.cloud_type => gw.gw_name...
  }

  primary_gateways_by_cloud_type = {
    for cloud_type, gateways in local.all_gateways_by_cloud_type :
    cloud_type => [
      for gw in gateways : gw if !endswith(gw, "-hagw")
    ]
  }

  same_cloud_peering = {
    for cloud_type, gateways in local.primary_gateways_by_cloud_type :
    cloud_type => gateways if length(gateways) > 1
  }

  all_primary_gateway_names = flatten(values(local.primary_gateways_by_cloud_type))

  prune_list = flatten([
    for cloud_type, gateways in local.same_cloud_peering : [
      for i, gw1 in gateways : [
        for j, gw2 in gateways :
        { "gateway_1" = gw1, "gateway_2" = gw2 } if i < j
      ]
    ]
  ])
}

module "same_cloud_peering" {
  for_each = local.same_cloud_peering

  source  = "terraform-aviatrix-modules/mc-transit-peering/aviatrix"
  version = "1.0.9"

  transit_gateways = each.value

  enable_peering_over_private_network = false

  create_peerings                             = true
  enable_insane_mode_encryption_over_internet = false
  enable_max_performance                      = true
  enable_single_tunnel_mode                   = false
  excluded_cidrs                              = []
  tunnel_count                                = null
}

module "cross_cloud_peering" {
  source  = "terraform-aviatrix-modules/mc-transit-peering/aviatrix"
  version = "1.0.9"

  transit_gateways = local.all_primary_gateway_names

  enable_peering_over_private_network = false

  prune_list = local.prune_list

  create_peerings                             = length(local.all_primary_gateway_names) > 1
  enable_insane_mode_encryption_over_internet = true
  enable_max_performance                      = true
  enable_single_tunnel_mode                   = false
  excluded_cidrs                              = []
  tunnel_count                                = 20
}
