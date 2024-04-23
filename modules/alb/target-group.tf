###################################################
# Target Group(s)
###################################################
resource "aws_lb_target_group" "this" {
  for_each = var.target_groups
  name     = each.key

  vpc_id = var.vpc_id

  target_type = each.value.target_type

  ip_address_type = try(each.value.ip_address_type, null)
  port            = each.value.target_type == "lambda" ? null : each.value.port
  protocol        = each.value.target_type == "lambda" ? null : each.value.protocol

  ## Attribute
  deregistration_delay          = try(each.value.deregistration_delay, 300)
  load_balancing_algorithm_type = try(each.value.load_balancing_algorithm_type, "least_outstanding_requests")
  slow_start                    = try(each.value.slow_start, 0)

  lambda_multi_value_headers_enabled = try(each.value.lambda_multi_value_headers_enabled, null)
  load_balancing_anomaly_mitigation  = try(each.value.load_balancing_anomaly_mitigation, null)
  load_balancing_cross_zone_enabled  = try(each.value.load_balancing_cross_zone_enabled, null)
  protocol_version                   = try(each.value.protocol_version, null)
  preserve_client_ip                 = try(each.value.preserve_client_ip, null)

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

  ## stickiness
  dynamic "stickiness" {
    for_each = try([each.value.stickiness], [])

    content {
      cookie_duration = try(stickiness.value.cookie_duration, null)
      cookie_name     = stickiness.value.type == "APP_COOKIE" ? stickiness.value.stickiness_cookie : null
      enabled         = try(stickiness.value.enabled, false)
      type            = try(stickiness.value.type, null)
    }
  }

  tags = merge(
    {
      "Name" : each.key
    },
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_partition" "current" {}

locals {
  targets = flatten([
    for target_group, target_values in var.taget_groups : [
      for target in target_values.targets : {
        name                      = "${target.target_group}/${target.target_id}"
        target_id                 = target.target_id
        target_group              = target_group
        target_type               = target_group.target_type
        port                      = target_group.target_type == "lambda" ? null : try(target.port, null)
        availability_zone         = try(target.availability_zone, null)
        lambda_function_name      = try(target.lambda_function_name, null)
        lambda_qualifier          = try(target.lambda_qualifier, null)
        lambda_statement_id       = try(target.lambda_statement_id, "AllowExecutionFromLb")
        lambda_action             = try(target.lambda_action, "lambda:InvokeFunction")
        lambda_principal          = try(target.lambda_principal, "elasticloadbalancing.${data.aws_partition.current.dns_suffix}")
        lambda_source_account     = try(arget.lambda_source_account, null)
        lambda_event_source_token = try(target.lambda_event_source_token, null)
      }
    ]
  ])
}

resource "aws_lb_target_group_attachment" "this" {
  for_each = {
    for target in local.targets : target.name => target
  }

  target_group_arn  = aws_lb_target_group.this[each.value.target_group].arn
  target_id         = each.value.target_id
  port              = each.value.target_type == "lambda" ? null : each.value.port
  availability_zone = each.value.availability_zone

  depends_on = [aws_lambda_permission.this]
}

resource "aws_lambda_permission" "this" {
  for_each = {
    for target in local.targets : target.name => target if target.target_type == "lambda"
  }
  function_name = each.value.lambda_function_name
  qualifier     = each.value.lambda_qualifier

  statement_id       = each.value.lambda_statement_id
  action             = each.value.lambda_action
  principal          = each.value.lambda_principal
  source_arn         = aws_lb_target_group.this[each.value.target_group].arn
  source_account     = each.value.lambda_source_account
  event_source_token = each.value.lambda_event_source_token
}
