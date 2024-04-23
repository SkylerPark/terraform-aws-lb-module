###################################################
# Application Load Balancer
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
    for_each = var.connection_log.enabled ? [var.connection_log] : []

    content {
      bucket  = connection_log.value.bucket
      enabled = connection_log.value.enabled
      prefix  = connection_log.value.prefix
    }
  }

  dynamic "access_logs" {
    for_each = var.access_log.enabled ? [var.access_log] : []

    content {
      bucket  = access_log.value.bucket
      enabled = access_log.value.enabled
      prefix  = access_log.value.prefix
    }
  }

  ## Attributes
  desync_mitigation_mode           = var.desync_mitigation_mode
  enable_cross_zone_load_balancing = var.cross_zone_load_balancing_enabled
  enable_deletion_protection       = var.deletion_protection_enabled
  enable_http2                     = var.http2_enabled
  enable_waf_fail_open             = var.waf_fail_open_enabled
  idle_timeout                     = var.idle_timeout

  ## Headers
  drop_invalid_header_fields                  = var.drop_invalid_header_fields
  enable_tls_version_and_cipher_suite_headers = var.tls_negotiation_headers_enabled
  preserve_host_header                        = var.preserve_host_header
  enable_xff_client_port                      = var.xff_header.client_port_preservation_enabled
  xff_header_processing_mode                  = lower(var.xff_header.mode)

  tags = merge(
    {
      "Name" = var.name
    },
    var.tags
  )
}
