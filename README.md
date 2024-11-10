<!-- BEGIN_TF_DOCS -->
# CFKE Connected Fleet for AWS

This module installs the required IAM roles and policies, and sets up the VPC for the CFKE controller to manage the cluster.

VPCs are created in all the enabled regions of the AWS account.

## Example usage

```terraform
module "cfke_connected_fleet" {
  source               = "registry.terraform.io/cloudfleetai/cfke-connected-fleet/aws"
  version              = "1.0.0"
  control_plane_region = "northamerica-central-1"
  cluster_id           = "ea4ba2ac-3262-4c51-9a08-e13c98e50aab"
}
```

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | The Cluster ID | `string` | n/a | yes |
| <a name="input_control_plane_region"></a> [control\_plane\_region](#input\_control\_plane\_region) | n/a | `string` | n/a | yes |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | The CIDR block for the VPC | `string` | `"10.0.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_fleet_arn"></a> [fleet\_arn](#output\_fleet\_arn) | The ARN of the IAM role for the CFKE controller. Use this when you create the Fleet for the cluster |

## License

[Apache License 2.0](LICENSE)
<!-- END_TF_DOCS -->