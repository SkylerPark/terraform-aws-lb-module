# alb-with-instance

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.20.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.20.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alb"></a> [alb](#module\_alb) | ../../modules/alb | n/a |
| <a name="module_alb_security_group"></a> [alb\_security\_group](#module\_alb\_security\_group) | git::https://github.com/SkylerPark/terraform-aws-vpc-module.git//modules/security-group/ | tags/1.1.0 |
| <a name="module_eip"></a> [eip](#module\_eip) | git::https://github.com/SkylerPark/terraform-aws-vpc-module.git//modules/elastic-ip/ | tags/1.1.0 |
| <a name="module_instance"></a> [instance](#module\_instance) | git::https://github.com/SkylerPark/terraform-aws-ec2-module.git//modules/instance/ | tags/1.1.2 |
| <a name="module_nat_gateway"></a> [nat\_gateway](#module\_nat\_gateway) | git::https://github.com/SkylerPark/terraform-aws-vpc-module.git//modules/nat-gateway/ | tags/1.1.0 |
| <a name="module_private_route_table"></a> [private\_route\_table](#module\_private\_route\_table) | git::https://github.com/SkylerPark/terraform-aws-vpc-module.git//modules/route-table/ | tags/1.1.0 |
| <a name="module_private_subnet_group"></a> [private\_subnet\_group](#module\_private\_subnet\_group) | git::https://github.com/SkylerPark/terraform-aws-vpc-module.git//modules/subnet-group/ | tags/1.1.0 |
| <a name="module_public_route_table"></a> [public\_route\_table](#module\_public\_route\_table) | git::https://github.com/SkylerPark/terraform-aws-vpc-module.git//modules/route-table/ | tags/1.1.0 |
| <a name="module_public_subnet_group"></a> [public\_subnet\_group](#module\_public\_subnet\_group) | git::https://github.com/SkylerPark/terraform-aws-vpc-module.git//modules/subnet-group/ | tags/1.1.0 |
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | git::https://github.com/SkylerPark/terraform-aws-vpc-module.git//modules/security-group/ | tags/1.1.0 |
| <a name="module_ssh_key"></a> [ssh\_key](#module\_ssh\_key) | git::https://github.com/SkylerPark/terraform-aws-ec2-module.git//modules/key-pair/ | tags/1.1.2 |
| <a name="module_target_group_v1"></a> [target\_group\_v1](#module\_target\_group\_v1) | ../../modules/alb-target-group | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | git::https://github.com/SkylerPark/terraform-aws-vpc-module.git//modules/vpc/ | tags/1.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_ami.amazon_linux2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
