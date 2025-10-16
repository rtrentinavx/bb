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
| <a name="input_external_devices"></a> [external\_devices](#input\_external\_devices) | Map of external devices to connect to Aviatrix Transit Gateways | <pre>map(object({<br/>    transit_key               = string<br/>    connection_name           = string<br/>    remote_gateway_ip         = string<br/>    bgp_enabled               = bool<br/>    bgp_remote_asn            = optional(string)<br/>    local_tunnel_cidr         = optional(string)<br/>    remote_tunnel_cidr        = optional(string)<br/>    ha_enabled                = bool<br/>    backup_remote_gateway_ip  = optional(string)<br/>    backup_local_tunnel_cidr  = optional(string)<br/>    backup_remote_tunnel_cidr = optional(string)<br/>    enable_ikev2              = optional(bool)<br/>    inspected_by_firenet      = bool<br/>  }))</pre> | `{}` | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | n/a | yes |
| <a name="input_tgws"></a> [tgws](#input\_tgws) | Map of AWS Transit Gateway configurations | <pre>map(object({<br/>    amazon_side_asn             = optional(number)<br/>    transit_gateway_cidr_blocks = optional(list(string), [])<br/>    create_tgw                  = bool                   # True to create TGW, false for existing<br/>    account_ids                 = optional(list(string)) # List of AWS account IDs to share with<br/>  }))</pre> | `{}` | no |
| <a name="input_transits"></a> [transits](#input\_transits) | Map of transit gateway configurations | <pre>map(object({<br/>    account                          = string<br/>    cidr                             = string<br/>    instance_size                    = string<br/>    local_as_number                  = number<br/>    bgp_manual_spoke_advertise_cidrs = optional(string, "")<br/>    fw_amount                        = optional(number, 0)<br/>    fw_instance_size                 = optional(string, "c5.xlarge")<br/>    firewall_image                   = optional(string, "")<br/>    firewall_image_version           = optional(string, "")<br/>    bootstrap_bucket_name_1          = optional(string, "")<br/>    tgw_name                         = optional(string, "")<br/>    inside_cidr_blocks = map(object({<br/>      connect_peer_1    = string<br/>      ha_connect_peer_1 = string<br/>      connect_peer_2    = string<br/>      ha_connect_peer_2 = string<br/>    }))<br/>  }))</pre> | `{}` | no |

## Outputs

No outputs.
