locals {
  # Map transit gateways to domains
  domain_names = {
    for idx, gw in data.aviatrix_transit_gateways.all_transit_gws.gateway_list :
    gw.gw_name => var.domains[idx % length(var.domains)]
  }
  # Map spoke gateways to domains, excluding HA gateways
  spoke_domain_names = {
    for idx, gw in data.aviatrix_spoke_gateways.all_spoke_gws.gateway_list :
    gw.gw_name => var.domains[idx % length(var.domains)]
    if !endswith(gw.gw_name, "-hagw")
  }
  # Ensure connections is defined
  connections = try(jsondecode(terracurl_request.aviatrix_connections.response)["results"], [])
}


resource "terracurl_request" "aviatrix_connections" {
  name            = "aviatrix_connections"
  url             = "https://${data.aws_ssm_parameter.aviatrix_ip.value}/v2/api"
  method          = "POST"
  skip_tls_verify = true
  request_body = jsonencode({
    action = "list_site2cloud"
    CID    = jsondecode(data.http.controller_login.response_body)["CID"]
  })
  headers = {
    "Content-Type" = "application/json"
  }
  response_codes = [200]
  depends_on     = [data.http.controller_login]

  destroy_url    = var.destroy_url
  destroy_method = "GET"

  lifecycle {
    postcondition {
      condition     = jsondecode(self.response)["return"]
      error_message = "Failed to create access account: ${jsondecode(self.response)["reason"]}"
    }

    ignore_changes = all
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
  for_each = merge(
    # Transit and spoke gateway connections
    {
      for entry in flatten([
        for conn in local.connections : [
          for gw_name in try(conn.gateway_list, []) : {
            key             = "${gw_name}.${conn.name}"
            gateway_name    = gw_name
            domain_name     = lookup(local.domain_names, gw_name, null) != null ? lookup(local.domain_names, gw_name, null) : lookup(local.spoke_domain_names, gw_name, null)
            connection_name = conn.name
          }
          if lookup(local.domain_names, gw_name, null) != null || lookup(local.spoke_domain_names, gw_name, null) != null
        ]
      ]) : entry.key => entry
    },
    # Direct spoke gateway associations
    {
      for gw in data.aviatrix_spoke_gateways.all_spoke_gws.gateway_list :
      "${gw.gw_name}.spoke" => {
        gateway_name    = gw.gw_name
        domain_name     = lookup(local.spoke_domain_names, gw.gw_name, null)
        connection_name = gw.gw_name
      }
      if lookup(local.spoke_domain_names, gw.gw_name, null) != null
    }
  )

  network_domain_name  = each.value.domain_name
  attachment_name      = each.value.connection_name
  transit_gateway_name = each.value.gateway_name

  depends_on = [
    aviatrix_segmentation_network_domain.domains,
    terracurl_request.aviatrix_connections,
    data.aviatrix_transit_gateways.all_transit_gws,
    data.aviatrix_spoke_gateways.all_spoke_gws,
  ]
}
