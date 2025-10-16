locals {
  domain_names = {
    for idx, gw in data.aviatrix_transit_gateways.all_transit_gws.gateway_list :
    gw.gw_name => var.domains[idx % length(var.domains)]
    if !endswith(gw.gw_name, "-hagw")
  }

  spoke_domain_names = {
    for idx, gw in data.aviatrix_spoke_gateways.all_spoke_gws.gateway_list :
    gw.gw_name => var.domains[idx % length(var.domains)]
    if !endswith(gw.gw_name, "-hagw")
  }

  connections = try(jsondecode(local.connections), [])

  associations = {
    for conn in local.connections :
    conn.name => {
      gateway_name    = split(",", conn.gw_name)[0]
      domain_name     = try(lookup(local.domain_names, split(",", conn.gw_name)[0], null), null)
      connection_name = conn.name
    }
    if try(lookup(local.domain_names, split(",", conn.gw_name)[0], null), null) != null
  }
}

resource "aviatrix_segmentation_network_domain" "domains" {
  for_each    = toset(var.domains)
  domain_name = each.key
}

resource "aviatrix_segmentation_network_domain_connection_policy" "segmentation_network_domain_connection_policy" {
  for_each      = { for idx, policy in var.connection_policy : "${policy.source}-${policy.target}" => policy }
  domain_name_1 = each.value.source
  domain_name_2 = each.value.target
  depends_on    = [aviatrix_segmentation_network_domain.domains]
}

resource "aviatrix_segmentation_network_domain_association" "domain_associations" {
  for_each = local.associations

  network_domain_name  = each.value.domain_name
  attachment_name      = each.value.connection_name
  transit_gateway_name = each.value.gateway_name

  depends_on = [
    aviatrix_segmentation_network_domain.domains,
    data.external.aviatrix_connections,
    data.aviatrix_transit_gateways.all_transit_gws,
    data.aviatrix_spoke_gateways.all_spoke_gws,
  ]
}