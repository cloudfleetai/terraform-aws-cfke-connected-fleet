<!-- BEGIN_TF_DOCS -->
# CFKE Connected Fleet for AWS

## Example usage

````terraform
module "vpn" {

  source    = "registry.terraform.io/cloudfleetai/cfke-connected-fleet/aws"
  version   = "1.0.0"
}
````

`

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.75.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy_document.AWSCloudFormationStackSetAdministrationRole_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.AWSCloudFormationStackSetExecutionRole_MinimumExecutionPolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.AWSCloudFormationStackSetExecutionRole_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.control-plane-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.trust_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_regions.all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/regions) | data source |
| [aws_regions.not_opted_in](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/regions) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | The Cluster ID | `string` | n/a | yes |
| <a name="input_control_plane_region"></a> [control\_plane\_region](#input\_control\_plane\_region) | n/a | `string` | n/a | yes |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | The CIDR block for the VPC | `string` | `"10.0.0.0/16"` | no |

## Outputs

No outputs.

## License

[Apache License 2.0](LICENSE)
<!-- END_TF_DOCS -->