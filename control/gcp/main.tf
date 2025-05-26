# Create NCC hubs for each network domain
resource "google_network_connectivity_hub" "ncc_hubs" {
  for_each = toset(["interconnect", "infra", "non-prod", "prod"])

  name        = "ncc-${each.value}"
  project     = var.hub_project_id
  description = "NCC hub for ${each.value} network domain"
}

# Create NCC spokes to attach VPCs to hubs
resource "google_network_connectivity_spoke" "ncc_spokes" {
  for_each = { for spoke in var.spokes : "${spoke.vpc_name}-${spoke.ncc_hub}" => spoke }

  name     = "${each.value.vpc_name}-spoke-${each.value.ncc_hub}"
  project  = each.value.project_id
  location = "global"
  hub      = google_network_connectivity_hub.ncc_hubs[each.value.ncc_hub].id

  linked_vpc_network {
    uri = "projects/${each.value.project_id}/global/networks/${each.value.vpc_name}"
  }

  depends_on = [
    google_network_connectivity_hub.ncc_hubs,
    google_compute_network.bgp_lan_vpcs
  ]
}

resource "google_network_connectivity_spoke" "avx_spokes" {
  for_each = { for pair in flatten([
    for transit in var.transits : [
      for intf_type, subnet in transit.bgp_lan_subnets : {
        gw_name    = transit.gw_name
        project_id = transit.project_id
        region     = transit.region
        subnet     = subnet
        intf_type  = intf_type
      } if subnet != ""
    ]
  ]) : "${pair.gw_name}-bgp-lan-${pair.intf_type}" => pair }

  name     = "${each.value.gw_name}-bgp-lan-${each.value.intf_type}-to-avx"
  project  = each.value.project_id
  location = each.value.region
  hub      = google_network_connectivity_hub.ncc_hubs[each.value.intf_type].id

  linked_router_appliance_instances {
    instances {
      virtual_machine = "projects/${each.value.project_id}/zones/${module.mc_transit[each.value.gw_name].transit_gateway.vpc_reg}/instances/${each.value.gw_name}"
      ip_address      = module.mc_transit[each.value.gw_name].transit_gateway.bgp_lan_ip_list[index(["interconnect", "infra", "non-prod", "prod"], each.value.intf_type)]
    }
    instances {
      virtual_machine = try(
        "projects/${each.value.project_id}/zones/${module.mc_transit[each.value.gw_name].transit_gateway.vpc_reg}/instances/${module.mc_transit[each.value.gw_name].ha_transit_gateway.gw_name}",
        "projects/${each.value.project_id}/zones/${module.mc_transit[each.value.gw_name].transit_gateway.ha_zone}/instances/${each.value.gw_name}-hagw"
      )
      ip_address = try(
        module.mc_transit[each.value.gw_name].transit_gateway.ha_bgp_lan_ip_list[index(["interconnect", "infra", "non-prod", "prod"], each.value.intf_type)],
        ""
      )
    }
    site_to_site_data_transfer = true
  }

  depends_on = [
    google_network_connectivity_hub.ncc_hubs,
    module.mc_transit
  ]
}

# Create GCP VPCs for BGP LAN interfaces
resource "google_compute_network" "bgp_lan_vpcs" {
  for_each = toset(["interconnect", "infra", "non-prod", "prod"])

  name                    = "bgp-lan-${each.value}-vpc"
  project                 = var.hub_project_id
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

# Create GCP subnets for each BGP LAN interface
resource "google_compute_subnetwork" "bgp_lan_subnets" {
  for_each = { for pair in flatten([
    for transit in var.transits : [
      for intf_type, subnet in transit.bgp_lan_subnets : {
        gw_name    = transit.gw_name
        project_id = transit.project_id
        region     = transit.region
        subnet     = subnet
        intf_type  = intf_type
      } if subnet != ""
    ]
  ]) : "${pair.gw_name}-bgp-lan-${pair.intf_type}" => pair }

  name          = "${each.value.gw_name}-bgp-lan-${each.value.intf_type}-subnet"
  project       = each.value.project_id
  region        = each.value.region
  network       = google_compute_network.bgp_lan_vpcs[each.value.intf_type].self_link
  ip_cidr_range = each.value.subnet
  depends_on    = [google_compute_network.bgp_lan_vpcs]
}

# Create Cloud Routers for each BGP LAN VPC
resource "google_compute_router" "bgp_lan_routers" {
  for_each = { for pair in flatten([
    for transit in var.transits : [
      for intf_type, subnet in transit.bgp_lan_subnets : {
        gw_name    = transit.gw_name
        project_id = transit.project_id
        region     = transit.region
        subnet     = subnet
        intf_type  = intf_type
        asn        = transit.cloud_router_asn
      } if subnet != ""
    ]
  ]) : "${pair.gw_name}-bgp-lan-${pair.intf_type}" => pair }

  name    = "${each.value.gw_name}-bgp-lan-${each.value.intf_type}-router"
  project = each.value.project_id
  region  = each.value.region
  network = google_compute_network.bgp_lan_vpcs[each.value.intf_type].self_link

  bgp {
    asn = each.value.asn
  }

  depends_on = [
    google_compute_network.bgp_lan_vpcs
  ]
}

# Allocate IPs for primary and HA interfaces
resource "google_compute_address" "bgp_lan_addresses" {
  for_each = { for pair in flatten([
    for transit in var.transits : [
      for intf_type, subnet in transit.bgp_lan_subnets : [
        {
          gw_name    = transit.gw_name
          project_id = transit.project_id
          region     = transit.region
          subnet     = subnet
          intf_type  = intf_type
          type       = "pri"
        },
        {
          gw_name    = transit.gw_name
          project_id = transit.project_id
          region     = transit.region
          subnet     = subnet
          intf_type  = intf_type
          type       = "ha"
        }
      ] if subnet != ""
    ]
  ]) : "${pair.gw_name}-bgp-lan-${pair.intf_type}-${pair.type}" => pair }

  name         = "${each.value.gw_name}-bgp-lan-${each.value.intf_type}-address-${each.value.type}"
  project      = each.value.project_id
  region       = each.value.region
  subnetwork   = google_compute_subnetwork.bgp_lan_subnets["${each.value.gw_name}-bgp-lan-${each.value.intf_type}"].self_link
  address_type = "INTERNAL"
}
# Create primary and HA Cloud Router interfaces
resource "google_compute_router_interface" "bgp_lan_interfaces_pri" {
  for_each = { for pair in flatten([
    for transit in var.transits : [
      for intf_type, subnet in transit.bgp_lan_subnets : {
        gw_name    = transit.gw_name
        project_id = transit.project_id
        region     = transit.region
        subnet     = subnet
        intf_type  = intf_type
      } if subnet != ""
    ]
  ]) : "${pair.gw_name}-bgp-lan-${pair.intf_type}" => pair }

  name                = "${each.value.gw_name}-bgp-lan-${each.value.intf_type}-int-pri"
  project             = each.value.project_id
  region              = each.value.region
  router              = google_compute_router.bgp_lan_routers[each.key].name
  subnetwork          = google_compute_subnetwork.bgp_lan_subnets[each.key].self_link
  private_ip_address  = google_compute_address.bgp_lan_addresses["${each.key}-pri"].address
  redundant_interface = google_compute_router_interface.bgp_lan_interfaces_ha[each.key].name

  depends_on = [
    google_compute_router.bgp_lan_routers,
    google_compute_subnetwork.bgp_lan_subnets,
    google_compute_address.bgp_lan_addresses
  ]
}

resource "google_compute_router_interface" "bgp_lan_interfaces_ha" {
  for_each = { for pair in flatten([
    for transit in var.transits : [
      for intf_type, subnet in transit.bgp_lan_subnets : {
        gw_name    = transit.gw_name
        project_id = transit.project_id
        region     = transit.region
        subnet     = subnet
        intf_type  = intf_type
      } if subnet != ""
    ]
  ]) : "${pair.gw_name}-bgp-lan-${pair.intf_type}" => pair }

  name               = "${each.value.gw_name}-bgp-lan-${each.value.intf_type}-int-hagw"
  project            = each.value.project_id
  region             = each.value.region
  router             = google_compute_router.bgp_lan_routers[each.key].name
  subnetwork         = google_compute_subnetwork.bgp_lan_subnets[each.key].self_link
  private_ip_address = google_compute_address.bgp_lan_addresses["${each.key}-ha"].address

  depends_on = [
    google_compute_router.bgp_lan_routers,
    google_compute_subnetwork.bgp_lan_subnets,
    google_compute_address.bgp_lan_addresses
  ]
}

#
# # Create Aviatrix BGP connections for each interface type
# resource "aviatrix_transit_external_device_conn" "bgp_lan_connections" {
#   for_each = { for pair in flatten([
#     for transit in var.transits : [
#       for intf_type, subnet in transit.bgp_lan_subnets : {
#         gw_name    = transit.gw_name
#         project_id = transit.project_id
#         region     = transit.region
#         subnet     = subnet
#         intf_type  = intf_type
#       } if subnet != ""
#     ]
#   ]) : "${pair.gw_name}-bgp-lan-${pair.intf_type}" => pair }

#   vpc_id                    = module.mc_transit[each.value.gw_name].transit_gateway.vpc_id
#   connection_name           = "${each.value.gw_name}-bgp-lan-${each.value.intf_type}-to-avx"
#   gw_name                   = each.value.gw_name
#   connection_type           = "bgp"
#   tunnel_protocol           = "LAN"
#   bgp_local_as_num          = [for t in var.transits : t.aviatrix_gw_asn if t.gw_name == each.value.gw_name][0]
#   bgp_remote_as_num         = [for t in var.transits : t.cloud_router_asn if t.gw_name == each.value.gw_name][0]
#   remote_lan_ip             = google_compute_address.bgp_lan_addresses["${each.key}-pri"].address
#   local_lan_ip              = module.mc_transit[each.value.gw_name].transit_gateway.bgp_lan_ip_list[index(["interconnect", "infra", "non-prod", "prod"], each.value.intf_type)]
#   ha_enabled                = true
#   backup_bgp_remote_as_num  = [for t in var.transits : t.cloud_router_asn if t.gw_name == each.value.gw_name][0]
#   backup_remote_lan_ip      = google_compute_address.bgp_lan_addresses["${each.key}-ha"].address
#   backup_local_lan_ip       = module.mc_transit[each.value.gw_name].transit_gateway.ha_bgp_lan_ip_list[index(["interconnect", "infra", "non-prod", "prod"], each.value.intf_type)]
#   enable_bgp_lan_activemesh = true

#   depends_on = [
#     module.mc_transit,
#     google_compute_address.bgp_lan_addresses
#   ]
# }

# Create Aviatrix Transit Gateways using mc-transit module
module "mc_transit" {
  for_each = { for transit in var.transits : transit.gw_name => transit }

  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "2.6.0"

  cloud                            = "gcp"
  region                           = each.value.region
  name                             = each.value.name
  gw_name                          = each.value.gw_name
  cidr                             = each.value.vpc_cidr
  account                          = each.value.access_account_name
  instance_size                    = each.value.gw_size
  ha_gw                            = true
  enable_bgp_over_lan              = true
  enable_transit_firenet           = false
  bgp_manual_spoke_advertise_cidrs = ""
  bgp_ecmp                         = true
  local_as_number                  = each.value.aviatrix_gw_asn

  bgp_lan_interfaces = [
    for intf_type in ["interconnect", "infra", "non-prod", "prod"] : {
      vpc_id     = google_compute_network.bgp_lan_vpcs[intf_type].name
      subnet     = each.value.bgp_lan_subnets[intf_type]
      create_vpc = false
    } if each.value.bgp_lan_subnets[intf_type] != ""
  ]

  ha_bgp_lan_interfaces = [
    for intf_type in ["interconnect", "infra", "non-prod", "prod"] : {
      vpc_id     = google_compute_network.bgp_lan_vpcs[intf_type].name
      subnet     = each.value.bgp_lan_subnets[intf_type]
      create_vpc = false
    } if each.value.bgp_lan_subnets[intf_type] != ""
  ]

  depends_on = [
    google_compute_network.bgp_lan_vpcs,
    google_compute_subnetwork.bgp_lan_subnets
  ]
}