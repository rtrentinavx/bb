locals {
  vpc_domain_map = {
    for vpc_id, vpc in data.aws_vpc.vpcs :
    try(lookup(coalesce(vpc.tags, {}), "domain", ""), "") => vpc.cidr_block
    if try(lookup(coalesce(vpc.tags, {}), "domain", ""), "") != ""
  }

  subnet_domain_map = {
    for subnet_id, subnet in data.aws_subnet.subnet_details :
    try(lookup(coalesce(subnet.tags, {}), "domain", ""), "") => data.aws_vpc.vpcs[subnet.vpc_id].cidr_block
    if try(lookup(coalesce(subnet.tags, {}), "domain", ""), "") != ""
  }

  domain_cidr_map = merge(local.subnet_domain_map, local.vpc_domain_map)

  unique_domains = distinct([
    for domain in keys(merge(local.vpc_domain_map, local.subnet_domain_map)) : domain
    if domain != ""
  ])

  domain_cidr_lists = {
    for domain in local.unique_domains :
    domain => distinct([
      for k, v in merge(local.vpc_domain_map, local.subnet_domain_map) : v
      if k == domain
    ])
  }

  smarties = { for domain, cidrs in local.domain_cidr_lists : domain => { cidrs = cidrs } }

  smart_groups_map = {
    for domain, group in aviatrix_smart_group.smarties : domain => group.uuid
  }

  valid_policies = {
    for name, policy in var.policies :
    name => policy
    if alltrue([
      for sg in concat(policy.src_smart_groups, policy.dst_smart_groups, policy.web_groups) :
      contains(local.unique_domains, sg)
    ])
  }

  default_policies = [
    {
      name                     = "Greenfield-Rule"
      action                   = "PERMIT"
      src_smart_groups         = ["def000ad-0000-0000-0000-000000000000"]
      dst_smart_groups         = ["def000ad-0000-0000-0000-000000000000"]
      priority                 = 2147483646
      exclude_sg_orchestration = true
      protocol                 = "ANY"
      logging                  = false
      watch                    = false
      flow_app_requirement     = "APP_UNSPECIFIED"
      system_resource          = false
      decrypt_policy           = "DECRYPT_UNSPECIFIED"
      desc                     = ""
      intrusion_severity       = "INTRUSION_SEVERITY_NONE"
      web_groups               = []   # Explicitly set to empty list to match var.policies structure
      is_default_policy        = true # Flag to indicate default policy
    },
    {
      name                     = "DefaultDenyAll"
      action                   = "DENY"
      src_smart_groups         = ["def000ad-0000-0000-0000-000000000000"]
      dst_smart_groups         = ["def000ad-0000-0000-0000-000000000000"]
      priority                 = 2147483647
      exclude_sg_orchestration = true
      protocol                 = "ANY"
      logging                  = false
      watch                    = false
      flow_app_requirement     = "APP_UNSPECIFIED"
      system_resource          = true
      decrypt_policy           = "DECRYPT_UNSPECIFIED"
      desc                     = ""
      intrusion_severity       = "INTRUSION_SEVERITY_NONE"
      web_groups               = []   # Explicitly set to empty list to match var.policies structure
      is_default_policy        = true # Flag to indicate default policy
    }
  ]

}

resource "aviatrix_smart_group" "smarties" {
  for_each = local.smarties
  name     = "smart-group-${each.key}"

  dynamic "selector" {
    for_each = each.value.cidrs
    content {
      match_expressions {
        cidr = selector.value
      }
    }
  }
}

resource "aviatrix_distributed_firewalling_policy_list" "policies" {
  dynamic "policies" {
    for_each = concat(
      local.default_policies,
      [for key, value in local.valid_policies : merge(value, { name = key, is_default_policy = false })]
    )
    content {
      name                     = policies.value.name
      action                   = policies.value.action
      priority                 = policies.value.priority
      protocol                 = policies.value.protocol
      logging                  = policies.value.logging
      watch                    = policies.value.watch
      src_smart_groups         = policies.value.is_default_policy ? policies.value.src_smart_groups : [for sg in policies.value.src_smart_groups : local.smart_groups_map[sg]]
      dst_smart_groups         = policies.value.is_default_policy ? policies.value.dst_smart_groups : [for sg in policies.value.dst_smart_groups : local.smart_groups_map[sg]]
      web_groups               = length(policies.value.web_groups) > 0 ? [for sg in policies.value.web_groups : local.smart_groups_map[sg]] : []
      flow_app_requirement     = policies.value.flow_app_requirement
      decrypt_policy           = policies.value.decrypt_policy
      exclude_sg_orchestration = policies.value.exclude_sg_orchestration

      dynamic "port_ranges" {
        for_each = (policies.value.protocol != "icmp" && length(lookup(policies.value, "port_ranges", [])) > 0) ? lookup(policies.value, "port_ranges", []) : []
        content {
          lo = tonumber(port_ranges.value)
          hi = tonumber(port_ranges.value)
        }
      }
    }
  }
  depends_on = [aviatrix_smart_group.smarties]
}