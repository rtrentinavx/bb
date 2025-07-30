locals {
  domain_pairs = [
    for policy in var.connection_policy :
    sort([policy.source, policy.target])
  ]

  unique_domains = toset(flatten(local.domain_pairs))

  connection_data_raw = try(jsondecode(terracurl_request.aviatrix_connections.response).results.connections, [])

  spoke_gateways = { for gw in data.aviatrix_spoke_gateways.all_spoke_gws.gateway_list : gw.gw_name => gw }

  transit_connections = { for conn in local.connection_data_raw : conn.name => conn if strcontains(lower(try(conn.tunnel_type, "")), "transit") && !endswith(coalesce(split(":", try(conn.vpc_id, ""))[0], conn.gw_name, ""), "-hagw") }

  connection_data = {
    for domain in local.unique_domains : domain => flatten(
      concat(
        [
          for gw_name, gw in local.spoke_gateways : {
            connection_name = gw_name
            source_gateway  = gw_name
            source_type     = "spoke"
          } if strcontains(lower(gw_name), lower(domain)) && !contains([for k, v in local.connection_data_raw : v.name if strcontains(lower(v.name), lower(domain))], gw_name)
        ],
        [
          for conn_name, conn in local.transit_connections : {
            connection_name = conn_name
            source_gateway  = conn_name
            source_type     = "transit"
          } if strcontains(lower(conn_name), lower(domain)) && !contains([for k, v in local.spoke_gateways : v.gw_name if strcontains(lower(v.gw_name), lower(domain))], conn_name)
        ]
      )
    )
  }

  domain_connection_pairs = flatten([
    for domain, connections in local.connection_data : [
      for conn in connections : {
        domain          = domain
        connection_name = conn.connection_name
        source_gateway  = conn.source_gateway
        source_type     = conn.source_type
      } if conn.source_type == "spoke" || conn.source_type == "transit"
    ]
  ])
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
  domain_name = each.value
}

resource "aviatrix_segmentation_network_domain_connection_policy" "test_segmentation_network_domain_connection_policy" {
  for_each      = { for idx, policy in var.connection_policy : "${policy.source}-${policy.target}" => policy }
  domain_name_1 = each.value.source
  domain_name_2 = each.value.target
  depends_on    = [aviatrix_segmentation_network_domain.domains]
}

resource "aviatrix_segmentation_network_domain_association" "domain_associations" {
  for_each = {
    for pair in local.domain_connection_pairs :
    "${pair.domain}-${pair.connection_name}" => pair
  }

  network_domain_name = each.value.domain
  attachment_name     = each.value.connection_name

  depends_on = [aviatrix_segmentation_network_domain.domains, terracurl_request.aviatrix_connections]
}