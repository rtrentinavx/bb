## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_transit"></a> [transit](#module\_transit) | ./modules/transit | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_ssm_region"></a> [aws\_ssm\_region](#input\_aws\_ssm\_region) | n/a | `string` | n/a | yes |
| <a name="input_hub_project_id"></a> [hub\_project\_id](#input\_hub\_project\_id) | GCP project ID for NCC hubs | `string` | n/a | yes |
| <a name="input_ncc_hubs"></a> [ncc\_hubs](#input\_ncc\_hubs) | List of NCC hubs to create | <pre>list(object({<br/>    name            = string<br/>    create          = optional(bool, true)<br/>    preset_topology = optional(string, "STAR")<br/>  }))</pre> | `[]` | no |
| <a name="input_spokes"></a> [spokes](#input\_spokes) | n/a | <pre>list(object({<br/>    vpc_name   = string<br/>    project_id = string<br/>    ncc_hub    = string<br/>  }))</pre> | `[]` | no |
| <a name="input_transits"></a> [transits](#input\_transits) | n/a | <pre>list(object({<br/>    gw_name                 = string<br/>    project_id              = string<br/>    region                  = string<br/>    name                    = string<br/>    vpc_cidr                = string<br/>    gw_size                 = string<br/>    access_account_name     = string<br/>    cloud_router_asn        = number<br/>    aviatrix_gw_asn         = number<br/>    bgp_lan_subnets         = map(string)<br/>    fw_amount               = optional(number, 0)<br/>    fw_instance_size        = optional(string, "n1-standard-4")<br/>    firewall_image          = optional(string, "")<br/>    firewall_image_version  = optional(string, "")<br/>    bootstrap_bucket_name_1 = optional(string, "")<br/>    lan_cidr                = optional(string, "")<br/>    mgmt_cidr               = optional(string, "")<br/>    egress_cidr             = optional(string, "")<br/>    manual_bgp_advertised_cidrs = optional(set(string), [])<br/>  }))</pre> | n/a | yes |

## Outputs

No outputs.
