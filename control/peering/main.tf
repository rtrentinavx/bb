locals {
  gw_name_to_cloud_type = {
    for gw in data.aviatrix_transit_gateways.all_transit_gws.gateway_list :
    replace(gw.gw_name, ",", "-") => gw.cloud_type # Sanitize gateway names
  }

  all_gateways_by_cloud_type = {
    for gw in data.aviatrix_transit_gateways.all_transit_gws.gateway_list :
    gw.cloud_type => replace(gw.gw_name, ",", "-")...
  }

  primary_gateways_by_cloud_type = {
    for cloud_type, gateways in local.all_gateways_by_cloud_type :
    cloud_type => [
      for gw in gateways : gw if !endswith(gw, "-hagw")
    ]
  }

  # List of gateways for same-cloud peering (per cloud type with multiple gateways)
  same_cloud_peering = {
    for cloud_type, gateways in local.primary_gateways_by_cloud_type :
    cloud_type => gateways if length(gateways) > 1
  }

  # All primary gateways for cross-cloud peering
  all_primary_gateway_names = flatten(values(local.primary_gateways_by_cloud_type))

  # Optional: Prune list to exclude same-cloud pairs in cross-cloud peering
  cross_cloud_prune_list = flatten([
    for cloud_type, gateways in local.same_cloud_peering : [
      for i, gw1 in gateways : [
        for j, gw2 in gateways : {
          gateway_1 = gw1
          gateway_2 = gw2
        } if i < j
      ]
    ]
  ])
}

module "same_cloud_peering" {
  for_each = local.same_cloud_peering

  source  = "terraform-aviatrix-modules/mc-transit-peering/aviatrix"
  version = "1.0.9"

  transit_gateways = each.value

  enable_peering_over_private_network         = false
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
  prune_list = [
    for pair in local.cross_cloud_prune_list : {
      "${pair.gateway_1}" = pair.gateway_2
    }
  ]

  enable_peering_over_private_network         = false
  create_peerings                             = true
  enable_insane_mode_encryption_over_internet = true
  enable_max_performance                      = true
  enable_single_tunnel_mode                   = false
  excluded_cidrs                              = []
  tunnel_count                                = 15
}