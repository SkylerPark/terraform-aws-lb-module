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
  description = "network load balancer attribute 값."
  value = {
    cross_zone_load_balancing_enabled           = aws_lb.this.enable_cross_zone_load_balancing
    deletion_protection_enabled                 = aws_lb.this.enable_deletion_protection
    route53_resolver_availability_zone_affinity = var.route53_resolver_availability_zone_affinity
  }
}

output "listener" {
  description = "load balancer listener 정보 리스트"
  value = {
    for listener in var.listeners : "${aws_lb.this.name}-${aws_lb_listener.this[listener.port].protocol}:${listener.port}" => {
      arn      = aws_lb_listener.this[listener.port].arn
      id       = aws_lb_listener.this[listener.port].id
      port     = aws_lb_listener.this[listener.port].port
      protocol = aws_lb_listener.this[listener.port].protocol
      default_actions = {
        forward = {
          target_group = [
            for target in [listener.target_group] : {
              arn = target
            }
          ]
        }
      }
      tls = try({
        certificate = aws_lb_listener.this[listener.port].certificate_arn
        additional_certificates = [
          for certificate in values(aws_lb_listener_certificate.this) :
          certificate.certificate_arn
        ]
        security_policy = aws_lb_listener.this[listener.port].security_policy
        alpn_policy     = aws_lb_listener.this[listener.port].alpn_policy
      }, null)
    }
  }
}

output "target_groups" {
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
          enabled = aws_lb_target_group.this[target_group].stickiness[0].enabled
          type    = upper(aws_lb_target_group.this[target_group].stickiness[0].type)
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
