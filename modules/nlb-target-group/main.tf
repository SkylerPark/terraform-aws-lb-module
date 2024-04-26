###################################################
# Target Group
###################################################
resource "aws_lb_target_group" "this" {
  name = var.name

  vpc_id      = var.vpc_id
  target_type = var.target_type

  ip_address_type = var.ip_address_type
  port            = var.port
  protocol        = var.protocol

  ## Attribute
  proxy_protocol_v2      = var.proxy_protocol_v2
  preserve_client_ip     = var.preserve_client_ip
  connection_termination = var.connection_termination
  deregistration_delay   = var.deregistration_delay

  stickiness {
    enabled = var.stickiness_enabled
    type    = "source_ip"
  }

  ## health check
  dynamic "health_check" {
    for_each = try([var.health_check], [])

    content {
      enabled             = try(health_check.value.enabled, null)
      healthy_threshold   = try(health_check.value.healthy_threshold, null)
      interval            = try(health_check.value.interval, null)
      matcher             = try(health_check.value.matcher, null)
      path                = try(health_check.value.path, null)
      port                = try(health_check.value.port, null)
      protocol            = try(health_check.value.protocol, null)
      timeout             = try(health_check.value.timeout, null)
      unhealthy_threshold = try(health_check.value.unhealthy_threshold, null)
    }
  }

  tags = merge(
    {
      "Name" : var.name
    },
    var.tags
  )
}

###################################################
# Target Group Attachment
###################################################
resource "aws_lb_target_group_attachment" "this" {
  for_each = var.targets

  target_group_arn  = aws_lb_target_group.this.arn
  target_id         = each.value.target_id
  port              = each.value.port
  availability_zone = each.value.availability_zone
}
