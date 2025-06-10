locals {
  stripped_names = {
    for k, v in var.transits : k => (
      length(regexall("^(.+)-vnet$", k)) > 0 ?
      regex("^(.+)-vnet$", k)[0] : k
    )
  }

  vwan_names = toset(flatten([
    [for t in var.transits : [for c in t.vwan_connections : c.vwan_name if try(c.vwan_name != "", false)]],
    [for v in var.vnets : v.vwan_name if v.vwan_name != ""]
  ]))

  vwan_hub_to_vwan = merge(
    { for t in flatten([
      for t in var.transits : [
        for c in t.vwan_connections : {
          vwan_hub_name = c.vwan_hub_name
          vwan_name     = c.vwan_name
        } if try(c.vwan_hub_name != "", false)
      ]
      ]) : t.vwan_hub_name => t.vwan_name...
    },
    { for v in var.vnets : v.vwan_hub_name => [v.vwan_name] if v.vwan_hub_name != "" }
  )

  vwan_hub_to_location = { for k, v in var.vwan_hubs : k => v.location }

  vwan_hub_names = { for k, v in var.vwan_hubs : k => "${k}-${lower(replace(v.location, " ", ""))}-hub" }

  vwan_hub_name_from_hub = { for k, v in local.vwan_hub_names : v => k }

  vwan_hub_info = {
    for k, v in var.vwan_hubs : k => {
      location         = v.location
      virtual_hub_cidr = v.virtual_hub_cidr
      azure_asn        = 65515
    }
  }

  vwan_names_per_transit = {
    for transit_key, transit in var.transits : transit_key => toset([
      for conn in transit.vwan_connections : conn.vwan_name if try(conn.vwan_hub_name != "", false)
    ])
  }

  all_vwan_hub_names = toset(values(local.vwan_hub_names))

  # Parse VNet peering to extract hub VNet details
  transit_peering_details = {
    for transit_key, transit in var.transits : transit_key => {
      peering_id          = length(data.azurerm_virtual_network.transit_vnet[transit_key].vnet_peerings) > 0 ? values(data.azurerm_virtual_network.transit_vnet[transit_key].vnet_peerings)[0] : ""
      split_data          = length(data.azurerm_virtual_network.transit_vnet[transit_key].vnet_peerings) > 0 ? split("/", values(data.azurerm_virtual_network.transit_vnet[transit_key].vnet_peerings)[0]) : []
      hub_vnet_name       = length(data.azurerm_virtual_network.transit_vnet[transit_key].vnet_peerings) > 0 ? split("/", values(data.azurerm_virtual_network.transit_vnet[transit_key].vnet_peerings)[0])[8] : ""
      hub_resource_group  = length(data.azurerm_virtual_network.transit_vnet[transit_key].vnet_peerings) > 0 ? split("/", values(data.azurerm_virtual_network.transit_vnet[transit_key].vnet_peerings)[0])[4] : ""
      hub_subscription_id = length(data.azurerm_virtual_network.transit_vnet[transit_key].vnet_peerings) > 0 ? split("/", values(data.azurerm_virtual_network.transit_vnet[transit_key].vnet_peerings)[0])[2] : ""
    }
  }

  transit_vwan_pairs = flatten([
    for transit_key, transit in var.transits : [
      for idx, conn in transit.vwan_connections : {
        transit_key   = transit_key
        vwan_name     = conn.vwan_name
        vwan_hub_name = conn.vwan_hub_name
        bgp_lan_ips = {
          primary = module.mc-transit[transit_key].transit_gateway.bgp_lan_ip_list[0]
          ha      = module.mc-transit[transit_key].transit_gateway.ha_bgp_lan_ip_list[0]
        }
        pair_key        = "${transit_key}.${conn.vwan_hub_name}.${idx}"
        remote_vpc_name = "${local.transit_peering_details[transit_key].hub_vnet_name}:${local.transit_peering_details[transit_key].hub_resource_group}:${local.transit_peering_details[transit_key].hub_subscription_id}"
      } if try(conn.vwan_hub_name != "", false) && contains(keys(var.vwan_hubs), conn.vwan_hub_name)
    ] if length(transit.vwan_connections) > 0
  ])

  transit_vwan_map = { for pair in local.transit_vwan_pairs : pair.pair_key => pair }

  vwan_connect_ip = {
    for pair in local.transit_vwan_pairs : pair.pair_key => {
      hub_ip_primary = azurerm_virtual_hub.hub[pair.vwan_hub_name].virtual_router_ips[0]
      hub_ip_ha      = azurerm_virtual_hub.hub[pair.vwan_hub_name].virtual_router_ips[1]
    }
  }
}

resource "azurerm_resource_group" "vwan_rg" {
  for_each = { for k, v in var.vwan_hubs : k => v }
  name     = "rg-vwan-${lower(each.key)}"
  location = each.value.location
}

resource "azurerm_resource_group" "transit_rg" {
  for_each = var.transits
  name     = "rg-transit-${lower(each.key)}-${lower(replace(each.value.region, " ", ""))}"
  location = each.value.region
}

resource "azurerm_resource_group" "vnet_rg" {
  for_each = var.vnets
  name     = "rg-vnet-${lower(each.key)}-${lower(replace(each.value.region, " ", ""))}"
  location = each.value.region
}

resource "azurerm_virtual_wan" "vwan" {
  for_each            = { for k, v in var.vwan_hubs : k => v }
  name                = "vwan-${each.key}"
  resource_group_name = azurerm_resource_group.vwan_rg[each.key].name
  location            = each.value.location
  type                = "Standard"
}

resource "azurerm_virtual_hub" "hub" {
  for_each            = { for k, v in var.vwan_hubs : k => v }
  name                = "${each.key}-${lower(replace(each.value.location, " ", ""))}-hub"
  resource_group_name = azurerm_resource_group.vwan_rg[each.key].name
  location            = each.value.location
  virtual_wan_id      = azurerm_virtual_wan.vwan[each.key].id
  address_prefix      = each.value.virtual_hub_cidr
  sku                 = "Standard"
}

module "mc-transit" {
  for_each = var.transits
  source   = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version  = "2.6.0"

  account                       = each.value.account
  cloud                         = "azure"
  cidr                          = each.value.cidr
  region                        = each.value.region
  instance_size                 = each.value.instance_size
  name                          = each.key
  gw_name                       = local.stripped_names[each.key]
  local_as_number               = each.value.local_as_number
  enable_transit_firenet        = try(each.value.fw_amount, 0) > 0 ? true : false
  enable_bgp_over_lan           = true
  bgp_ecmp                      = true
  enable_segmentation           = true
  enable_advertise_transit_cidr = true
  insane_mode                   = true
  resource_group                = azurerm_resource_group.transit_rg[each.key].name
  bgp_lan_interfaces_count      = min(try(each.value.fw_amount, 0) > 0 ? length(local.vwan_names_per_transit[each.key]) + 1 : length(local.vwan_names_per_transit[each.key]), 3)
}

module "mc-firenet" {
  for_each = { for k, v in var.transits : k => v if v.fw_amount > 0 }
  source   = "terraform-aviatrix-modules/mc-firenet/aviatrix"
  version  = "1.6.0"

  transit_module         = module.mc-transit[each.key]
  firewall_image         = "Palo Alto Networks VM-Series Next-Generation Firewall (BYOL)"
  firewall_image_version = "10.2.14"
  instance_size          = each.value.fw_instance_size
  egress_enabled         = true
  fw_amount              = each.value.fw_amount
}

resource "azurerm_virtual_network" "vnet" {
  for_each            = var.vnets
  name                = each.key
  resource_group_name = azurerm_resource_group.vnet_rg[each.key].name
  location            = each.value.region
  address_space       = [each.value.cidr]
}

resource "azurerm_subnet" "private_subnet" {
  for_each             = { for k, v in var.vnets : k => v if length(v.private_subnets) > 0 }
  name                 = "${each.key}-private"
  resource_group_name  = azurerm_resource_group.vnet_rg[each.key].name
  virtual_network_name = azurerm_virtual_network.vnet[each.key].name
  address_prefixes     = each.value.private_subnets
}

resource "azurerm_subnet" "public_subnet" {
  for_each             = { for k, v in var.vnets : k => v if length(v.public_subnets) > 0 }
  name                 = "${each.key}-public"
  resource_group_name  = azurerm_resource_group.vnet_rg[each.key].name
  virtual_network_name = azurerm_virtual_network.vnet[each.key].name
  address_prefixes     = each.value.public_subnets
}

resource "azurerm_virtual_hub_connection" "transit_connection" {
  for_each                  = local.transit_vwan_map
  name                      = "${each.value.transit_key}-to-vwan-${each.value.vwan_name}"
  virtual_hub_id            = azurerm_virtual_hub.hub[each.value.vwan_hub_name].id
  remote_virtual_network_id = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${module.mc-transit[each.value.transit_key].vpc.resource_group}/providers/Microsoft.Network/virtualNetworks/${module.mc-transit[each.value.transit_key].vpc.name}"
  routing {
    propagated_route_table {
      route_table_ids = [azurerm_virtual_hub.hub[each.value.vwan_hub_name].default_route_table_id]
    }
  }
}

resource "azurerm_virtual_hub_connection" "vnet_connection" {
  for_each                  = { for k, v in var.vnets : k => v if v.vwan_name != "" }
  name                      = "${each.key}-to-vwan-${each.value.vwan_name}"
  virtual_hub_id            = azurerm_virtual_hub.hub[each.value.vwan_hub_name].id
  remote_virtual_network_id = azurerm_virtual_network.vnet[each.key].id
  routing {
    propagated_route_table {
      route_table_ids = [azurerm_virtual_hub.hub[each.value.vwan_hub_name].default_route_table_id]
    }
  }
}

resource "azurerm_virtual_hub_bgp_connection" "peer_avx_prim" {
  for_each                      = local.transit_vwan_map
  name                          = "${each.value.transit_key}-peer-prim"
  virtual_hub_id                = azurerm_virtual_hub.hub[each.value.vwan_hub_name].id
  peer_asn                      = module.mc-transit[each.value.transit_key].transit_gateway.local_as_number
  peer_ip                       = each.value.bgp_lan_ips.primary
  virtual_network_connection_id = azurerm_virtual_hub_connection.transit_connection[each.key].id
}

resource "azurerm_virtual_hub_bgp_connection" "peer_avx_ha" {
  for_each                      = local.transit_vwan_map
  name                          = "${each.value.transit_key}-peer-ha"
  virtual_hub_id                = azurerm_virtual_hub.hub[each.value.vwan_hub_name].id
  peer_asn                      = module.mc-transit[each.value.transit_key].transit_gateway.local_as_number
  peer_ip                       = each.value.bgp_lan_ips.ha
  virtual_network_connection_id = azurerm_virtual_hub_connection.transit_connection[each.key].id
}

resource "aviatrix_transit_external_device_conn" "external" {
  for_each                  = local.transit_vwan_map
  vpc_id                    = module.mc-transit[each.value.transit_key].vpc.vpc_id
  connection_name           = "vwan-connection-${each.value.vwan_hub_name}-${each.value.transit_key}"
  gw_name                   = module.mc-transit[each.value.transit_key].transit_gateway.gw_name
  connection_type           = "bgp"
  tunnel_protocol           = "LAN"
  remote_vpc_name           = each.value.remote_vpc_name
  ha_enabled                = true
  bgp_local_as_num          = module.mc-transit[each.value.transit_key].transit_gateway.local_as_number
  bgp_remote_as_num         = local.vwan_hub_info[each.value.vwan_hub_name].azure_asn
  backup_bgp_remote_as_num  = local.vwan_hub_info[each.value.vwan_hub_name].azure_asn
  remote_lan_ip             = local.vwan_connect_ip[each.key].hub_ip_primary
  backup_remote_lan_ip      = local.vwan_connect_ip[each.key].hub_ip_ha
  local_lan_ip              = each.value.bgp_lan_ips.primary
  backup_local_lan_ip       = each.value.bgp_lan_ips.ha
  enable_bgp_lan_activemesh = true
  direct_connect            = false
  custom_algorithms         = false
  enable_edge_segmentation  = false
  phase1_local_identifier   = null
  depends_on = [
    azurerm_virtual_hub_connection.transit_connection,
    data.azurerm_virtual_network.transit_vnet
  ]
  lifecycle {
    ignore_changes = all
  }
}

resource "aviatrix_segmentation_network_domain" "segmentation_network_domain" {
  for_each    = local.transit_vwan_map
  domain_name = each.value.vwan_hub_name
}

resource "aviatrix_segmentation_network_domain" "infra" {
  domain_name = "infra"
}

resource "aviatrix_segmentation_network_domain_association" "external_segmentation_association" {
  for_each            = local.transit_vwan_map
  network_domain_name = each.value.vwan_hub_name
  attachment_name     = aviatrix_transit_external_device_conn.external[each.key].connection_name
  depends_on = [
    aviatrix_segmentation_network_domain.segmentation_network_domain,
    aviatrix_segmentation_network_domain.infra
  ]
}

resource "aviatrix_segmentation_network_domain_connection_policy" "to_infra" {
  for_each      = { for name in local.all_vwan_hub_names : name => name if name != "infra" }
  domain_name_1 = each.value
  domain_name_2 = "infra"
  depends_on = [
    aviatrix_segmentation_network_domain.segmentation_network_domain,
    aviatrix_segmentation_network_domain.infra
  ]
}