output "arn" {
  description = "listener arn"
  value       = aws_lb_listener.this.arn
}

output "id" {
  description = "listener id"
  value       = aws_lb_listener.this.id
}

output "port" {
  description = "listener port"
  value       = aws_lb_listener.this.port
}

output "protocol" {
  description = "listener protocol"
  value       = aws_lb_listener.this.protocol
}

output "default_action" {
  description = "listener default action 정보"
  value = {
    forward = (var.default_action_type == "FORWARD" ?
      {
        target_group = [
          for target in [var.default_action_parameters.target_group] : {
            arn = target
          }
        ]
      }
    : null)
    weighted_forward = (var.default_action_type == "WEIGHTED_FORWARD" ?
      {
        target_group = [
          for target in var.default_action_parameters.targets : {
            arn    = target.targer_group
            weight = target.weight
          }
        ]
        stickiness = try({
          enabled  = aws_lb_listener.this.default_action[0].forward[0].stickiness[0].enabled
          duration = aws_lb_listener.this.default_action[0].forward[0].stickiness[0].duration
        }, null)
      }
    : null)
    fixed_response = try({
      status_code  = aws_lb_listener.this.default_action[0].fixed_response[0].status_code
      content_type = aws_lb_listener.this.default_action[0].fixed_response[0].content_type
      data         = aws_lb_listener.this.default_action[0].fixed_response[0].message_body
    }, null)
    redirect = try({
      status_code = split("_", aws_lb_listener.this.default_action[0].redirect[0].status_code)[1]
      protocol    = aws_lb_listener.this.default_action[0].redirect[0].protocol
      host        = aws_lb_listener.this.default_action[0].redirect[0].host
      port        = aws_lb_listener.this.default_action[0].redirect[0].port
      path        = aws_lb_listener.this.default_action[0].redirect[0].path
      query       = aws_lb_listener.this.default_action[0].redirect[0].query
      url = format(
        "%s://%s:%s%s?%s",
        lower(aws_lb_listener.this.default_action[0].redirect[0].protocol),
        aws_lb_listener.this.default_action[0].redirect[0].host,
        aws_lb_listener.this.default_action[0].redirect[0].port,
        aws_lb_listener.this.default_action[0].redirect[0].path,
        aws_lb_listener.this.default_action[0].redirect[0].query,
      )
    }, null)
    authenticate_cognito = try({
      user_pool_arn                       = aws_lb_listener.this.default_action[0].authenticate_cognito[0].user_pool_arn
      user_pool_client_id                 = aws_lb_listener.this.default_action[0].authenticate_cognito[0].user_pool_client_id
      user_pool_domain                    = aws_lb_listener.this.default_action[0].authenticate_cognito[0].user_pool_domain
      session_timeout                     = aws_lb_listener.this.default_action[0].authenticate_cognito[0].session_timeout
      session_cookie_name                 = aws_lb_listener.this.default_action[0].authenticate_cognito[0].session_cookie_name
      scope                               = aws_lb_listener.this.default_action[0].authenticate_cognito[0].scope
      on_unauthenticated_request          = aws_lb_listener.this.default_action[0].authenticate_cognito[0].on_unauthenticated_request
      authentication_request_extra_params = aws_lb_listener.this.default_action[0].authenticate_cognito[0].authentication_request_extra_params
      }, null
    )
    authenticate_oidc = try({
      authentication_request_extra_params = aws_lb_listener.this.default_action[0].authenticate_oidc[0].authentication_request_extra_params
      authorization_endpoint              = aws_lb_listener.this.default_action[0].authenticate_oidc[0].authorization_endpoint
      client_id                           = aws_lb_listener.this.default_action[0].authenticate_oidc[0].client_id
      client_secret                       = aws_lb_listener.this.default_action[0].authenticate_oidc[0].client_secret
      issuer                              = aws_lb_listener.this.default_action[0].authenticate_oidc[0].issuer
      on_unauthenticated_request          = aws_lb_listener.this.default_action[0].authenticate_oidc[0].on_unauthenticated_request
      scope                               = aws_lb_listener.this.default_action[0].authenticate_oidc[0].scope
      session_cookie_name                 = aws_lb_listener.this.default_action[0].authenticate_oidc[0].session_cookie_name
      session_timeout                     = aws_lb_listener.this.default_action[0].authenticate_oidc[0].session_timeout
      token_endpoint                      = aws_lb_listener.this.default_action[0].authenticate_oidc[0].token_endpoint
      user_info_endpoint                  = aws_lb_listener.this.default_action[0].authenticate_oidc[0].user_info_endpoint
      }, null
    )
  }
}

locals {
  output_rules = {
    for rule in var.rules :
    rule.priority => {
      conditions = rule.conditions
      action = {
        type                 = rule.action_type
        parameters           = rule.action_parameters
        forward              = try(aws_lb_listener_rule.this[rule.priority].action[0].forward[0], null)
        fixed_response       = try(aws_lb_listener_rule.this[rule.priority].action[0].fixed_response[0], null)
        redirect             = try(aws_lb_listener_rule.this[rule.priority].action[0].redirect[0], null)
        authenticate_cognito = try(aws_lb_listener_rule.this[rule.priority].action[0].authenticate_cognito[0], null)
        authenticate_oidc    = try(aws_lb_listener_rule.this[rule.priority].action[0].authenticate_oidc[0], null)
      }
    }
  }
}

output "rules" {
  description = "listener 추가 rules 정보"
  value = {
    for priority, rule in local.output_rules :
    priority => {
      conditions = rule.conditions
      action = {
        type = rule.action.type
        forward = (rule.action.type == "FORWARD"
          ? {
            target_group = {
              arn = rule.action.parameters.target_group
            }
          }
          : null
        )
        weighted_forward = (rule.action.type == "WEIGHTED_FORWARD"
          ? {
            targets = [
              for target in rule.action.parameters.targets : {
                target_group = {
                  arn = target.target_group
                }
                weight = try(target.weight, 1)
              }
            ]
            stickiness = {
              enabled  = rule.action.forward.stickiness[0].enabled
              duration = rule.action.forward.stickiness[0].duration
            }
          }
          : null
        )
        fixed_response = (rule.action.type == "FIXED_RESPONSE"
          ? {
            status_code  = rule.action.fixed_response.status_code
            content_type = rule.action.fixed_response.content_type
            data         = rule.action.fixed_response.message_body
          }
          : null
        )
        redirect = (contains(["REDIRECT_301", "REDIRECT_302"], rule.action.type)
          ? {
            status_code = split("_", rule.action.redirect.status_code)[1]
            protocol    = rule.action.redirect.protocol
            host        = rule.action.redirect.host
            port        = rule.action.redirect.port
            path        = rule.action.redirect.path
            query       = rule.action.redirect.query
            url = format(
              "%s://%s:%s%s?%s",
              lower(rule.action.redirect.protocol),
              rule.action.redirect.host,
              rule.action.redirect.port,
              rule.action.redirect.path,
              rule.action.redirect.query,
            )
          }
          : null
        )
        authenticate_cognito = (rule.action.type == "AUTHENTICATE_COGNITO") ? {
          user_pool_arn                       = rule.action.authenticate_cognito.user_pool_arn
          user_pool_client_id                 = rule.action.authenticate_cognito.user_pool_client_id
          user_pool_domain                    = rule.action.authenticate_cognito.user_pool_domain
          session_timeout                     = rule.action.authenticate_cognito.session_timeout
          session_cookie_name                 = rule.action.authenticate_cognito.session_cookie_name
          scope                               = rule.action.authenticate_cognito.scope
          on_unauthenticated_request          = rule.action.authenticate_cognito.on_unauthenticated_request
          authentication_request_extra_params = rule.action.authenticate_cognito.authentication_request_extra_params
        } : null
        authenticate_oidc = (rule.action.type == "AUTHENTICATE_COGNITO") ? {
          authentication_request_extra_params = rule.action.authenticate_oidc.authentication_request_extra_params
          authorization_endpoint              = rule.action.authenticate_oidc.authorization_endpoint
          client_id                           = rule.action.authenticate_oidc.client_id
          client_secret                       = rule.action.authenticate_oidc.client_secret
          issuer                              = rule.action.authenticate_oidc.issuer
          on_unauthenticated_request          = rule.action.authenticate_oidc.on_unauthenticated_request
          scope                               = rule.action.authenticate_oidc.scope
          session_cookie_name                 = rule.action.authenticate_oidc.session_cookie_name
          session_timeout                     = rule.action.authenticate_oidc.session_timeout
          token_endpoint                      = rule.action.authenticate_oidc.token_endpoint
          user_info_endpoint                  = rule.action.authenticate_oidc.user_info_endpoint
        } : null
      }
    }
  }
}

output "tls" {
  description = "listener TLS 정보"
  value = var.protocol == "HTTPS" ? {
    certificate = aws_lb_listener.this.certificate_arn
    additional_certificates = [
      for certificate in values(aws_lb_listener_certificate.this) :
      certificate.certificate_arn
    ]
    security_policy = aws_lb_listener.this.ssl_policy
  } : null
}
