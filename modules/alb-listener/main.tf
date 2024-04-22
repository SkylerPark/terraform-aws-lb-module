###################################################
# Listener
###################################################
resource "aws_lb_listener" "this" {
  load_balancer_arn = var.load_balancer
  port              = var.port
  protocol          = var.protocol

  certificate_arn = var.protocol == "HTTPS" ? var.tls.certificate : null
  ssl_policy      = var.protocol == "HTTPS" ? var.tls.security_policy : null

  ## forward
  dynamic "default_action" {
    for_each = (each.value.default_action_type == "FORWARD"
      ? [each.value.default_action_parameters] :
      []
    )

    content {
      type             = "forward"
      order            = try(default_action.value.order, null)
      target_group_arn = default_action.value.target_group
    }
  }

  ## weighted forward
  dynamic "default_action" {
    for_each = (each.value.default_action_type == "WEIGHTED_FORWARD"
      ? [var.default_action_parameters]
      : []
    )

    content {
      type  = "forward"
      order = try(default_action.value.order, null)

      forward {
        dynamic "target_group" {
          for_each = default_action.value.targets

          content {
            arn    = target_group.value.target_group
            weight = try(target_group.value.weight, 1)
          }
        }
        dynamic "stickiness" {
          for_each = try(default_action.value.stickiness_duration, 0) > 0 ? [1] : []

          content {
            enabled  = true
            duration = default_action.value.stickiness_duration
          }
        }
      }
    }
  }

  ## fixed response
  dynamic "default_action" {
    for_each = (var.default_action_type == "FIXED_RESPONSE"
      ? [var.default_action_parameters]
      : []
    )

    content {
      type  = "fixed-response"
      order = try(default_action.value.order, null)

      fixed_response {
        status_code  = try(default_action.value.status_code, 503)
        content_type = try(default_action.value.content_type, "text/plain")
        message_body = try(default_action.value.data, "")
      }
    }
  }

  ## authenticate cognito
  dynamic "default_action" {
    for_each = (var.default_action_type == "AUTHENTICATE_COGNITO"
      ? [var.default_action_parameters]
      : []
    )

    content {
      type  = "authenticate-cognito"
      order = try(default_action.value.order, null)

      authenticate_cognito {
        authentication_request_extra_params = try(default_action.value.authentication_request_extra_params, null)
        on_unauthenticated_request          = try(default_action.value.on_unauthenticated_request, null)
        scope                               = try(default_action.value.scope, null)
        session_cookie_name                 = try(default_action.value.session_cookie_name, null)
        session_timeout                     = try(default_action.value.session_timeout, null)
        user_pool_arn                       = default_action.value.user_pool_arn
        user_pool_client_id                 = default_action.value.user_pool_client_id
        user_pool_domain                    = default_action.value.user_pool_domain
      }
    }
  }

  ## authenticate oidc
  dynamic "default_action" {
    for_each = (var.default_action_type == "AUTHENTICATE_OIDC"
      ? [var.default_action_parameters]
      : []
    )

    content {
      type  = "authenticate-oidc"
      order = try(default_action.value.order, null)

      authenticate_oidc {
        authentication_request_extra_params = try(default_action.value.authentication_request_extra_params, null)
        authorization_endpoint              = default_action.value.authorization_endpoint
        client_id                           = default_action.value.client_id
        client_secret                       = default_action.value.client_secret
        issuer                              = default_action.value.issuer
        on_unauthenticated_request          = try(default_action.value.on_unauthenticated_request, null)
        scope                               = try(default_action.value.scope, null)
        session_cookie_name                 = try(default_action.value.session_cookie_name, null)
        session_timeout                     = try(default_action.value.session_timeout, null)
        token_endpoint                      = default_action.value.token_endpoint
        user_info_endpoint                  = default_action.value.user_info_endpoint
      }
    }
  }

  ## redirect 301
  dynamic "default_action" {
    for_each = (var.default_action_type == "REDIRECT_301"
      ? [var.default_action_parameters]
      : []
    )

    content {
      type  = "redirect"
      order = try(default_action.value.order, null)

      redirect {
        status_code = "HTTP_301"
        protocol    = try(default_action.value.protocol, "#{protocol}")
        host        = try(default_action.value.host, "#{host}")
        port        = try(default_action.value.port, "#{port}")
        path        = try(default_action.value.path, "/#{path}")
        query       = try(default_action.value.query, "#{query}")
      }
    }
  }

  ## redirect 302
  dynamic "default_action" {
    for_each = (var.default_action_type == "REDIRECT_302"
      ? [var.default_action_parameters]
      : []
    )

    content {
      type  = "redirect"
      order = try(default_action.value.order, null)

      redirect {
        status_code = "HTTP_302"
        protocol    = try(default_action.value.protocol, "#{protocol}")
        host        = try(default_action.value.host, "#{host}")
        port        = try(default_action.value.port, "#{port}")
        path        = try(default_action.value.path, "/#{path}")
        query       = try(default_action.value.query, "#{query}")
      }
    }
  }

  tags = merge(
    var.tags
  )
}

###################################################
# Listener Rule(s)
###################################################
resource "aws_lb_listener_rule" "this" {
  for_each = {
    for rule in var.rules :
    rule.priority => rule
  }

  listener_arn = aws_lb_listener.this.arn

  priority = each.key

  dynamic "condition" {
    for_each = try(each.value.conditions, [])

    content {
      dynamic "host_header" {
        for_each = condition.value.type == "HOST" ? ["go"] : []

        content {
          values = condition.value.values
        }
      }

      dynamic "http_request_method" {
        for_each = condition.value.type == "HTTP_METHOD" ? ["go"] : []

        content {
          values = condition.value.values
        }
      }

      dynamic "http_header" {
        for_each = condition.value.type == "HTTP_HEADER" ? ["go"] : []

        content {
          http_header_name = condition.value.name
          values           = condition.value.values
        }
      }

      dynamic "path_pattern" {
        for_each = condition.value.type == "PATH" ? ["go"] : []

        content {
          values = condition.value.values
        }
      }

      dynamic "query_string" {
        for_each = condition.value.type == "QUERY" ? condition.value.values : []

        content {
          key   = try(query_string.value.key, null)
          value = query_string.value.value
        }
      }

      dynamic "source_ip" {
        for_each = condition.value.type == "SOURCE_IP" ? ["go"] : []

        content {
          values = condition.value.values
        }
      }
    }
  }

  dynamic "action" {
    for_each = (each.value.action_type == "FORWARD"
      ? [each.value.action_parameters]
      : []
    )

    content {
      type = "forward"

      target_group_arn = action.value.target_group
    }
  }

  dynamic "action" {
    for_each = (each.value.action_type == "WEIGHTED_FORWARD"
      ? [each.value.action_parameters]
      : []
    )

    content {
      type = "forward"

      forward {
        dynamic "target_group" {
          for_each = action.value.targets

          content {
            arn    = target_group.value.target_group
            weight = try(target_group.value.weight, 1)
          }
        }
        dynamic "stickiness" {
          for_each = try(action.value.stickiness_duration, 0) > 0 ? ["go"] : []

          content {
            enabled  = true
            duration = action.value.stickiness_duration
          }
        }
      }
    }
  }

  dynamic "action" {
    for_each = (each.value.action_type == "FIXED_RESPONSE"
      ? [each.value.action_parameters]
      : []
    )

    content {
      type = "fixed-response"

      fixed_response {
        status_code  = try(action.value.status_code, 503)
        content_type = try(action.value.content_type, "text/plain")
        message_body = try(action.value.data, "")
      }
    }
  }

  dynamic "action" {
    for_each = (each.value.action_type == "REDIRECT_301"
      ? [each.value.action_parameters]
      : []
    )

    content {
      type = "redirect"

      redirect {
        status_code = "HTTP_301"
        protocol    = try(action.value.protocol, "#{protocol}")
        host        = try(action.value.host, "#{host}")
        port        = try(action.value.port, "#{port}")
        path        = try(action.value.path, "/#{path}")
        query       = try(action.value.query, "#{query}")
      }
    }
  }

  dynamic "action" {
    for_each = (each.value.action_type == "REDIRECT_302"
      ? [each.value.action_parameters]
      : []
    )

    content {
      type = "redirect"

      redirect {
        status_code = "HTTP_302"
        protocol    = try(action.value.protocol, "#{protocol}")
        host        = try(action.value.host, "#{host}")
        port        = try(action.value.port, "#{port}")
        path        = try(action.value.path, "/#{path}")
        query       = try(action.value.query, "#{query}")
      }
    }
  }

  tags = merge(
    {
      "Name" = "${var.name}/${each.key}"
    },
    var.tags,
  )
}
