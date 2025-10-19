## Spoke Gateway Naming Convention

The spokes should carry the network domain they will belong to:

- <any string except - >-<network domain name including - >-<any string except ->

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aviatrix"></a> [aviatrix](#requirement\_aviatrix) | 3.2.2 |

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
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | n/a | yes |
| <a name="input_spokes"></a> [spokes](#input\_spokes) | Map of spoke gateway configurations for Aviatrix. | <pre>map(object({<br/>    account         = string<br/>    cidr            = string<br/>    instance_size   = string<br/>    local_as_number = number<br/>    vwan_connections = list(object({<br/>      vwan_name     = string<br/>      vwan_hub_name = string<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | n/a | `string` | n/a | yes |
| <a name="input_transits"></a> [transits](#input\_transits) | Map of transit gateway configurations for Aviatrix. | <pre>map(object({<br/>    account                = string<br/>    cidr                   = string<br/>    instance_size          = string<br/>    local_as_number        = number<br/>    fw_amount              = optional(number, 0)<br/>    fw_instance_size       = optional(string)<br/>    firewall_image         = optional(string)<br/>    firewall_image_version = optional(string)<br/>    vwan_connections = list(object({<br/>      vwan_name     = string<br/>      vwan_hub_name = string<br/>    }))<br/>    bootstrap_storage_name_1 = optional(string, "")<br/>    storage_access_key_1     = optional(string, "")<br/>  }))</pre> | `{}` | no |
| <a name="input_vnets"></a> [vnets](#input\_vnets) | Map of VNET configurations for new or pre-existing VNETs to connect to Virtual WAN hubs. | <pre>map(object({<br/>    resource_group_name = optional(string)<br/>    existing            = optional(bool, false)<br/>    cidr                = optional(string)<br/>    private_subnets     = optional(list(string), [])<br/>    public_subnets      = optional(list(string), [])<br/>    vwan_hub_name       = string<br/>  }))</pre> | `{}` | no |
| <a name="input_vwan_configs"></a> [vwan\_configs](#input\_vwan\_configs) | Map of Virtual WAN configurations (new or existing). | <pre>map(object({<br/>    resource_group_name = string<br/>    location            = optional(string) # Required for new vWANs<br/>    existing            = bool             # True for existing vWANs, false for new<br/>  }))</pre> | `{}` | no |
| <a name="input_vwan_hubs"></a> [vwan\_hubs](#input\_vwan\_hubs) | Map of Virtual WAN hub configurations. | <pre>map(object({<br/>    virtual_hub_cidr                       = string<br/>    virtual_router_auto_scale_min_capacity = optional(number)<br/>  }))</pre> | `{}` | no |

## Outputs

No outputs.
