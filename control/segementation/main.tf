 resource "aviatrix_segmentation_network_domain" "segmentation_network_domain" {
   for_each    = local.transit_tgw_map
   domain_name = each.value.tgw_name
 }

 resource "aviatrix_segmentation_network_domain_association" "external-1-segmentation_network_domain_association" {
   for_each            = local.transit_tgw_map
   network_domain_name = each.value.tgw_name
   attachment_name     = aviatrix_transit_external_device_conn.external-1[each.key].connection_name
   depends_on          = [aviatrix_segmentation_network_domain.segmentation_network_domain]
 }

 resource "aviatrix_segmentation_network_domain_association" "external-2-segmentation_network_domain_association" {
   for_each            = local.transit_tgw_map
   network_domain_name = each.value.tgw_name
   attachment_name     = aviatrix_transit_external_device_conn.external-2[each.key].connection_name
   depends_on          = [aviatrix_segmentation_network_domain.segmentation_network_domain]
 }

 resource "aviatrix_segmentation_network_domain_connection_policy" "to_infra" {
   for_each = { for name in local.all_tgw_names : name => name if name != "infra" }

   domain_name_1 = each.value
   domain_name_2 = "infra"

   depends_on = [aviatrix_segmentation_network_domain.segmentation_network_domain]
# }
