###################################################
# Network Load Balancer
###################################################
resource "aws_lb" "this" {
  name               = var.name
  load_balancer_type = "network"
  internal           = !var.is_public
  ip_address_type    = lower(var.ip_address_type)

  dynamic "subnet_mapping" {
    for_each = var.network_mapping

    content {
      allocation_id        = try(subnet_mapping.value.elastic_ip, null)
      ipv6_address         = try(subnet_mapping.value.ipv6_cidr, null)
      private_ipv4_address = try(subnet_mapping.value.ipv4_cidr, null)
      subnet_id            = subnet_mapping.value.subnet
    }
  }

  ## Access Control
  enforce_security_group_inbound_rules_on_private_link_traffic = (length(local.security_groups) > 0
    ? (var.security_group_evaluation_on_privatelink_enabled ? "on" : "off")
    : null
  )
  security_groups = local.security_groups

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
  enable_cross_zone_load_balancing = var.cross_zone_load_balancing_enabled
  enable_deletion_protection       = var.deletion_protection_enabled

  tags = merge(
    {
      "Name" = var.name
    },
    var.tags
  )
}
