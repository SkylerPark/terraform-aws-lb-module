###################################################
# Security Group
###################################################
module "security_group" {
  source = "git::https://github.com/SkylerPark/terraform-aws-vpc-module.git//modules/security-group/?ref=tags/1.1.0"
  count  = var.default_security_group.enabled ? 1 : 0

  name        = coalesce(var.default_security_group.name, var.name)
  description = var.default_security_group.description
  vpc_id      = var.vpc_id

  revoke_rules_on_delete = true

  ingress_rules = var.default_security_group.ingress_rules
  egress_rules  = var.default_security_group.egress_rules

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
