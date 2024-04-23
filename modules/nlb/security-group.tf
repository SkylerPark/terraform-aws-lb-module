###################################################
# Security Group
###################################################
module "security_group" {
  source = "git::https://github.com/SkylerPark/terraform-aws-vpc-module.git//modules/vpc/?ref=tags/1.1.0"
  count  = var.security_group.enabled ? 1 : 0

  name        = coalesce(var.security_group.name, var.name)
  description = var.security_group.description
  vpc_id      = var.vpc_id

  revoke_rules_on_delete = true

  ingress_rules = var.security_group.ingress_rules
  egress_rules  = var.security_group.egress_rules

  tags = var.tags
}

locals {
  security_groups = concat(
    (var.default_security_group.enabled
      ? module.security_group[*].id
      : []
    ),
    var.security_groups,
  )
}
