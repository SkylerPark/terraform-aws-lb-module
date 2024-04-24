output "arn" {
  description = "load balancer ARN"
  value       = aws_lb.this.arn
}

output "arn_suffix" {
  description = "load balancer ARN suffix"
  value       = aws_lb.this.arn_suffix
}

output "name" {
  description = "load balancer Name"
  value       = aws_lb.this.name
}

output "type" {
  description = "load balancer type"
  value       = aws_lb.this.load_balancer_type
}

output "zone_id" {
  description = "Route53 별칭 레코드에 사용되는 load balancer 호스팅 영역 ID."
  value       = aws_lb.this.zone_id
}

output "domain" {
  description = "load balancer DNS name."
  value       = aws_lb.this.dns_name
}

output "is_public" {
  description = "load balancer public 으로 할당중인지 여부"
  value       = !aws_lb.this.internal
}

output "ip_address_type" {
  description = "load balancer IP Type."
  value       = upper(aws_lb.this.ip_address_type)
}

output "vpc_id" {
  description = "load balancer 가 생성된 VPC ID"
  value       = aws_lb.this.vpc_id
}

output "subnets" {
  description = "load balancer 가 생성된 subnet IDs"
  value       = aws_lb.this.subnets
}

output "default_security_group" {
  description = "load balancer 에 default security group ID."
  value       = one(module.security_group[*].id)
}

output "security_groups" {
  description = "load balancer security group Ids."
  value       = aws_lb.this.security_groups
}

output "access_log" {
  description = "load balancer Access log 설정값"
  value       = var.access_log
}

output "attributes" {
  description = "application load balancer attribute 값."
  value = {
    cross_zone_load_balancing_enabled = aws_lb.this.enable_cross_zone_load_balancing
    desync_mitigation_mode            = upper(aws_lb.this.desync_mitigation_mode)
    deletion_protection_enabled       = aws_lb.this.enable_deletion_protection
    http2_enabled                     = aws_lb.this.enable_http2
    waf_fail_open_enabled             = aws_lb.this.enable_waf_fail_open
    idle_timeout                      = aws_lb.this.idle_timeout

    tls_negotiation_headers_enabled = aws_lb.this.enable_tls_version_and_cipher_suite_headers
    drop_invalid_header_fields      = aws_lb.this.drop_invalid_header_fields
    preserve_host_header            = aws_lb.this.preserve_host_header
    xff_header = {
      mode                             = upper(aws_lb.this.xff_header_processing_mode)
      client_port_preservation_enabled = aws_lb.this.enable_xff_client_port
    }
  }
}

output "listeners" {
  description = "load balancer listener 정보 리스트"
  value = {
    for listener in var.listeners : "${aws_lb.this.name}-${aws_lb_listener.this[listener.port].protocol}:${listener.port}" => {
      arn      = aws_lb_listener.this[listener.port].arn
      id       = aws_lb_listener.this[listener.port].id
      port     = aws_lb_listener.this[listener.port].port
      protocol = aws_lb_listener.this[listener.port].protocol
      default_actions = {
        forward = (listener.default_action_type == "FORWARD" ?
          {
            target_group = [
              for target in [listener.default_action_parameters.target_group] : {
                arn = target
              }
            ]
          }
        : null)
        weighted_forward = (listener.default_action_type == "WEIGHTED_FORWARD" ?
          {
            target_group = [
              for target in listener.default_action_parameters.targets : {
                arn    = target.targer_group
                weight = target.weight
              }
            ]
            stickiness = {
              enabled  = aws_lb_listener.this[listener.port].default_action[0].forward[0].stickiness[0].enabled
              duration = aws_lb_listener.this[listener.port].default_action[0].forward[0].stickiness[0].duration
            }
          }
        : null)
        fixed_response = try({
          status_code  = aws_lb_listener.this[listener.port].default_action[0].fixed_response[0].status_code
          content_type = aws_lb_listener.this[listener.port].default_action[0].fixed_response[0].content_type
          data         = aws_lb_listener.this[listener.port].default_action[0].fixed_response[0].message_body
        }, null)
        redirect = try({
          status_code = split("_", aws_lb_listener.this[listener.port].default_action[0].redirect[0].status_code)[1]
          protocol    = aws_lb_listener.this[listener.port].default_action[0].redirect[0].protocol
          host        = aws_lb_listener.this[listener.port].default_action[0].redirect[0].host
          port        = aws_lb_listener.this[listener.port].default_action[0].redirect[0].port
          path        = aws_lb_listener.this[listener.port].default_action[0].redirect[0].path
          query       = aws_lb_listener.this[listener.port].default_action[0].redirect[0].query
          url = format(
            "%s://%s:%s%s?%s",
            lower(aws_lb_listener.this[listener.port].default_action[0].redirect[0].protocol),
            aws_lb_listener.this[listener.port].default_action[0].redirect[0].host,
            aws_lb_listener.this[listener.port].default_action[0].redirect[0].port,
            aws_lb_listener.this[listener.port].default_action[0].redirect[0].path,
            aws_lb_listener.this[listener.port].default_action[0].redirect[0].query,
          )
        }, null)
        authenticate_cognito = try({
          user_pool_arn                       = aws_lb_listener.this[listener.port].default_action[0].authenticate_cognito[0].user_pool_arn
          user_pool_client_id                 = aws_lb_listener.this[listener.port].default_action[0].authenticate_cognito[0].user_pool_client_id
          user_pool_domain                    = aws_lb_listener.this[listener.port].default_action[0].authenticate_cognito[0].user_pool_domain
          session_timeout                     = aws_lb_listener.this[listener.port].default_action[0].authenticate_cognito[0].session_timeout
          session_cookie_name                 = aws_lb_listener.this[listener.port].default_action[0].authenticate_cognito[0].session_cookie_name
          scope                               = aws_lb_listener.this[listener.port].default_action[0].authenticate_cognito[0].scope
          on_unauthenticated_request          = aws_lb_listener.this[listener.port].default_action[0].authenticate_cognito[0].on_unauthenticated_request
          authentication_request_extra_params = aws_lb_listener.this[listener.port].default_action[0].authenticate_cognito[0].authentication_request_extra_params
          }, null
        )
        authenticate_oidc = try({
          authentication_request_extra_params = aws_lb_listener.this[listener.port].default_action[0].authenticate_oidc[0].authentication_request_extra_params
          authorization_endpoint              = aws_lb_listener.this[listener.port].default_action[0].authenticate_oidc[0].authorization_endpoint
          client_id                           = aws_lb_listener.this[listener.port].default_action[0].authenticate_oidc[0].client_id
          client_secret                       = aws_lb_listener.this[listener.port].default_action[0].authenticate_oidc[0].client_secret
          issuer                              = aws_lb_listener.this[listener.port].default_action[0].authenticate_oidc[0].issuer
          on_unauthenticated_request          = aws_lb_listener.this[listener.port].default_action[0].authenticate_oidc[0].on_unauthenticated_request
          scope                               = aws_lb_listener.this[listener.port].default_action[0].authenticate_oidc[0].scope
          session_cookie_name                 = aws_lb_listener.this[listener.port].default_action[0].authenticate_oidc[0].session_cookie_name
          session_timeout                     = aws_lb_listener.this[listener.port].default_action[0].authenticate_oidc[0].session_timeout
          token_endpoint                      = aws_lb_listener.this[listener.port].default_action[0].authenticate_oidc[0].token_endpoint
          user_info_endpoint                  = aws_lb_listener.this[listener.port].default_action[0].authenticate_oidc[0].user_info_endpoint
          }, null
        )
      }
      tls = try({
        certificate = aws_lb_listener.this[listener.port].certificate_arn
        additional_certificates = [
          for certificate in values(aws_lb_listener_certificate.this) :
          certificate.certificate_arn
        ]
        security_policy = aws_lb_listener.this[listener.port].security_policy
      }, null)
      rules = try({
        for rule in listener.rule : "${aws_lb.this.name}-${listener.protocol}:${listener.port}/${rule.priority}" => {
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
                      arn    = target.target_group
                      weight = try(target.weight, 1)
                    }
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
          }
        }
      }, null)
    }
  }
}

output "targer_groups" {
  description = "load balancer target group 정보 리스트"
  value = {
    for target_group, target_value in var.target_groups : target_group => {
      arn              = aws_lb_target_group.this[target_group].arn
      id               = aws_lb_target_group.this[target_group].id
      name             = aws_lb_target_group.this[target_group].name
      type             = upper(aws_lb_target_group.this[target_group].target_type)
      port             = aws_lb_target_group.this[target_group].port
      protocol         = aws_lb_target_group.this[target_group].protocol
      protocol_version = aws_lb_target_group.this[target_group].protocol_version
      targets = [
        for target in aws_lb_target_group_attachment.this : {
          target_id = target.target_id
          port      = target.port
        }
      ]
      attributes = {
        deregistration_delay     = aws_lb_target_group.this[target_group].deregistration_delay
        load_balancing_algorithm = upper(aws_lb_target_group.this[target_group].load_balancing_algorithm_type)
        slow_start_duration      = aws_lb_target_group.this[target_group].slow_start
        stickiness = {
          enabled  = aws_lb_target_group.this[target_group].stickiness[0].enabled
          type     = upper(aws_lb_target_group.this[target_group].stickiness[0].type)
          duration = aws_lb_target_group.this[target_group].stickiness[0].cookie_duration
          cookie   = try(target_value.stickiness_cookie, null)
        }
        health_check = {
          protocol      = aws_lb_target_group.this[target_group].health_check[0].protocol
          port          = aws_lb_target_group.this[target_group].health_check[0].port
          path          = aws_lb_target_group.this[target_group].health_check[0].path
          success_codes = aws_lb_target_group.this[target_group].health_check[0].matcher

          healthy_threshold   = aws_lb_target_group.this[target_group].health_check[0].healthy_threshold
          unhealthy_threshold = aws_lb_target_group.this[target_group].health_check[0].unhealthy_threshold
          interval            = aws_lb_target_group.this[target_group].health_check[0].interval
          timeout             = aws_lb_target_group.this[target_group].health_check[0].timeout
        }
      }
    }
  }
}
