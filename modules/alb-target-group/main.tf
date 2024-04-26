###################################################
# Target Group
###################################################
resource "aws_lb_target_group" "this" {
  name = var.name

  vpc_id      = var.vpc_id
  target_type = var.target_type

  ip_address_type = var.ip_address_type
  port            = var.target_type == "lambda" ? null : var.port
  protocol        = var.target_type == "lambda" ? null : var.protocol

  ## Attribute
  deregistration_delay          = var.deregistration_delay
  load_balancing_algorithm_type = var.load_balancing_algorithm_type
  slow_start                    = var.slow_start

  lambda_multi_value_headers_enabled = var.lambda_multi_value_headers_enabled
  load_balancing_anomaly_mitigation  = var.load_balancing_algorithm_type == "weighted_random" ? var.load_balancing_anomaly_mitigation_enabled : null
  load_balancing_cross_zone_enabled  = var.load_balancing_cross_zone_enabled
  protocol_version                   = var.protocol_version

  ## health check
  dynamic "health_check" {
    for_each = [var.health_check]

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

  ## stickiness
  dynamic "stickiness" {
    for_each = [var.stickiness]

    content {
      cookie_duration = try(stickiness.value.cookie_duration, null)
      cookie_name     = stickiness.value.type == "APP_COOKIE" ? stickiness.value.stickiness_cookie : null
      enabled         = try(stickiness.value.enabled, false)
      type            = try(stickiness.value.type, null)
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
  port              = var.target_type == "lambda" ? null : each.value.port
  availability_zone = var.target_type == "lambda" ? "all" : each.value.availability_zone

  depends_on = [aws_lambda_permission.this]
}

resource "aws_lambda_permission" "this" {
  for_each = {
    for key, target in var.targets : key => target if var.target_type == "lambda"
  }
  function_name = each.value.lambda_function_name
  qualifier     = each.value.lambda_qualifier

  statement_id       = each.value.lambda_statement_id
  action             = each.value.lambda_action
  principal          = each.value.lambda_principal
  source_arn         = aws_lb_target_group.this.arn
  source_account     = each.value.lambda_source_account
  event_source_token = each.value.lambda_event_source_token
}
