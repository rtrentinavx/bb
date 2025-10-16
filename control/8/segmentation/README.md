## Use Two-Stage Apply with -target
Apply the resources that for_each depends on:

terraform apply -target=data.aviatrix_spoke_gateways.all_spoke_gws -target=data.aviatrix_transit_gateways.all_transit_gws -target=terracurl_request.aviatrix_connections

Run a second apply to converge the full configuration:

terraform apply

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aviatrix"></a> [aviatrix](#requirement\_aviatrix) | 8.1.1 |
| <a name="requirement_terracurl"></a> [terracurl](#requirement\_terracurl) | >= 1.2.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aviatrix"></a> [aviatrix](#provider\_aviatrix) | 8.1.1 |
| <a name="provider_aws.ssm"></a> [aws.ssm](#provider\_aws.ssm) | 6.16.0 |
| <a name="provider_http"></a> [http](#provider\_http) | 3.5.0 |
| <a name="provider_terracurl"></a> [terracurl](#provider\_terracurl) | 2.1.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aviatrix_segmentation_network_domain.domains](https://registry.terraform.io/providers/AviatrixSystems/aviatrix/8.1.1/docs/resources/segmentation_network_domain) | resource |
| [aviatrix_segmentation_network_domain_association.domain_associations](https://registry.terraform.io/providers/AviatrixSystems/aviatrix/8.1.1/docs/resources/segmentation_network_domain_association) | resource |
| [aviatrix_segmentation_network_domain_connection_policy.segmentation_network_domain_connection_policy](https://registry.terraform.io/providers/AviatrixSystems/aviatrix/8.1.1/docs/resources/segmentation_network_domain_connection_policy) | resource |
| [terracurl_request.aviatrix_connections](https://registry.terraform.io/providers/devops-rob/terracurl/latest/docs/resources/request) | resource |
| [aviatrix_spoke_gateways.all_spoke_gws](https://registry.terraform.io/providers/AviatrixSystems/aviatrix/8.1.1/docs/data-sources/spoke_gateways) | data source |
| [aviatrix_transit_gateways.all_transit_gws](https://registry.terraform.io/providers/AviatrixSystems/aviatrix/8.1.1/docs/data-sources/transit_gateways) | data source |
| [aws_ssm_parameter.aviatrix_ip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.aviatrix_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.aviatrix_username](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [http_http.controller_login](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_ssw_region"></a> [aws\_ssw\_region](#input\_aws\_ssw\_region) | n/a | `string` | n/a | yes |
| <a name="input_connection_policy"></a> [connection\_policy](#input\_connection\_policy) | n/a | <pre>list(object({<br/>    source = string<br/>    target = string<br/>  }))</pre> | `[]` | no |
| <a name="input_destroy_url"></a> [destroy\_url](#input\_destroy\_url) | Dummy URL used by terracurl during destroy operations. | `string` | `"https://checkip.amazonaws.com"` | no |
| <a name="input_domains"></a> [domains](#input\_domains) | List of network domain names | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_connections_data"></a> [connections\_data](#output\_connections\_data) | n/a |
