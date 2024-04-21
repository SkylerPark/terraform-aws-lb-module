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

###################################################
# Security Group for Application Load Balancer
###################################################
resource "aws_lb" "this" {
  name               = var.name
  load_balancer_type = "application"
  internal           = !var.is_public
  ip_address_type    = lower(var.ip_address_type)
  security_groups    = local.security_groups

  dynamic "subnet_mapping" {
    for_each = var.network_mapping

    content {
      subnet_id = subnet_mapping.value.subnet
    }
  }

  dynamic "connection_logs" {
    for_each = var.connection_logs.enabled ? [var.connection_logs] : []

    content {
      bucket  = connection_logs.value.bucket
      enabled = connection_logs.value.enabled
      prefix  = connection_logs.value.prefix
    }
  }

  dynamic "access_logs" {
    for_each = var.access_logs.enabled ? [var.access_logs] : []

    content {
      bucket  = access_logs.value.bucket
      enabled = access_logs.value.enabled
      prefix  = access_logs.value.prefix
    }
  }

  ## Attributes
  desync_mitigation_mode           = lower(var.desync_mitigation_mode)
  enable_cross_zone_load_balancing = var.cross_zone_load_balancing_enabled
  enable_deletion_protection       = var.deletion_protection_enabled
  enable_http2                     = var.http2_enabled
  enable_waf_fail_open             = var.waf_fail_open_enabled
  idle_timeout                     = var.idle_timeout

  # Headers
  drop_invalid_header_fields                  = var.drop_invalid_header_fields
  enable_tls_version_and_cipher_suite_headers = var.tls_negotiation_headers_enabled
  preserve_host_header                        = var.preserve_host_header
  enable_xff_client_port                      = var.xff_header.client_port_preservation_enabled
  xff_header_processing_mode                  = lower(var.xff_header.mode)

  tags = merge(
    { "Name" = var.name },
    var.tags
  )
}

###################################################
# Listener for Application Load Balancer
###################################################