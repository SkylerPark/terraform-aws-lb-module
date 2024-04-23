###################################################
# Target Group(s)
###################################################
resource "aws_lb_target_group" "this" {
  for_each = var.target_groups
  name     = each.key

  vpc_id = var.vpc_id

  target_type     = each.value.target.type
  ip_address_type = try(each.value.ip_address_type, null)
  port            = each.value.port
  protocol        = each.value.protocol

  ## Attribute
  proxy_protocol_v2      = try(each.value.proxy_protocol_v2, null)
  preserve_client_ip     = try(each.value.preserve_client_ip, null)
  connection_termination = try(each.value.connection_termination, null)
  deregistration_delay   = try(each.value.deregistration_delay, null)

  ## health check
  dynamic "health_check" {
    for_each = try([each.value.health_check], [])

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
      "Name" : each.key
    },
    var.tags
  )
}

resource "aws_lb_target_group_attachment" "this" {
  for_each = var.target_groups

  target_group_arn  = aws_lb_target_group.this[each.key].arn
  target_id         = each.value.target_id
  port              = each.value.port
  availability_zone = try(each.value.availability_zone, null)
}
