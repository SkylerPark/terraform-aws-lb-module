###################################################
# Network Load Balancer
###################################################
locals {
  route53_resolver_availability_zone_affinity = {
    "ANY"     = "any_availability_zone"
    "PARTIAL" = "partial_availability_zone_affinity"
    "ALL"     = "availability_zone_affinity"
  }
}
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

  dynamic "access_logs" {
    for_each = var.access_log.enabled ? [var.access_log] : []

    content {
      bucket  = access_logs.value.bucket
      enabled = access_logs.value.enabled
      prefix  = access_logs.value.prefix
    }
  }

  ## Attributes
  dns_record_client_routing_policy = local.route53_resolver_availability_zone_affinity[var.route53_resolver_availability_zone_affinity]
  enable_cross_zone_load_balancing = var.cross_zone_load_balancing_enabled
  enable_deletion_protection       = var.deletion_protection_enabled

  tags = merge(
    {
      "Name" = var.name
    },
    var.tags
  )
}

module "listener" {
  source = "../nlb-listener"

  for_each = {
    for listener in var.listeners :
    listener.port => listener
  }

  load_balancer = aws_lb.this.arn

  port         = each.key
  protocol     = each.value.protocol
  target_group = each.value.target_group

  tls = {
    certificate             = each.value.tls.certificate
    additional_certificates = each.value.tls.additional_certificates
    security_policy         = each.value.tls.security_policy
    alpn_policy             = each.value.tls.alpn_policy
  }

  tags = var.tags
}
