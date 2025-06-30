locals {
  unique_domains = toset(flatten([
    for policy in var.connection_policy : [
      policy.source,
      policy.target
    ]
  ]))

  connection_data_raw = try(jsondecode(terracurl_request.aviatrix_connections.response).results.connections, [])

  connection_data = {
    for domain in local.unique_domains : domain => [
      for conn in local.connection_data_raw : {
        connection_name = try(conn.name, "")
        source_gateway  = try(split(":", conn.vpc_id)[0], conn.gw_name, "")
        source_type     = strcontains(lower(try(conn.tunnel_type, "")), "transit") ? "transit" : "spoke"
      } if try(conn.name, "") != "" && 
           strcontains(lower(try(conn.name, "")), lower(domain)) && 
           !endswith(try(split(":", conn.vpc_id)[0], conn.gw_name, ""), "-hagw") &&
           # Ensure exclusive domain matching by checking if this is the "best" domain
           sum([
             for d in local.unique_domains : 
             strcontains(lower(try(conn.name, "")), lower(d)) ? 1 : 0
           ]) == 1
    ]
  }

  domain_connection_pairs = flatten([
    for domain, connections in local.connection_data : [
      for conn in connections : {
        domain          = domain
        connection_name = conn.connection_name
        source_gateway  = conn.source_gateway
        source_type     = conn.source_type
      } if conn.source_type == "transit" # Only include transit connections
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
  for_each    = local.unique_domains
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