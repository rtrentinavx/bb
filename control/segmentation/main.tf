locals {
  connections = jsondecode(terracurl_request.aviatrix_connections.response)["results"]
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

# resource "aviatrix_segmentation_network_domain_association" "domain_associations" {
#   for_each = we need to loop trough the transit gateways 

#   network_domain_name = contained in the var.domain_names 
#   attachment_name     = external connections from the gateway we are looping in the for each 

# }