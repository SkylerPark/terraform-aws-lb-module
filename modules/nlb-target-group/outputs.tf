output "arn" {
  description = "target group arn"
  value       = aws_lb_target_group.this.arn
}

output "id" {
  description = "target group id"
  value       = aws_lb_target_group.this.id
}

output "name" {
  description = "target group 이름"
  value       = aws_lb_target_group.this.name
}

output "type" {
  description = "target group type"
  value       = upper(aws_lb_target_group.this.target_type)
}

output "port" {
  description = "target group port"
  value       = aws_lb_target_group.this.port
}

output "protocol" {
  description = "target group protocol"
  value       = aws_lb_target_group.this.protocol
}

output "protocol_version" {
  description = "target group protocol version"
  value       = aws_lb_target_group.this.protocol_version
}

output "targets" {
  description = "target group 에 포함 된 정보 리스트"
  value = {
    for name, target in aws_lb_target_group_attachment.this : name => {
      target_id = target.target_id
      port      = target.port
    }
  }
}

output "attributes" {
  description = "target group 에 attribute 값"
  value = {
    proxy_protocol_v2      = aws_lb_target_group.this.proxy_protocol_v2
    preserve_client_ip     = aws_lb_target_group.this.preserve_client_ip
    connection_termination = aws_lb_target_group.this.connection_termination
    deregistration_delay   = aws_lb_target_group.this.deregistration_delay
    stickiness = {
      enabled = aws_lb_target_group.this.stickiness[0].enabled
      type    = upper(aws_lb_target_group.this.stickiness[0].type)
    }
  }
}

output "health_check" {
  description = "target group health check 값"
  value = {
    protocol      = aws_lb_target_group.this.health_check[0].protocol
    port          = aws_lb_target_group.this.health_check[0].port
    path          = aws_lb_target_group.this.health_check[0].path
    success_codes = aws_lb_target_group.this.health_check[0].matcher

    healthy_threshold   = aws_lb_target_group.this.health_check[0].healthy_threshold
    unhealthy_threshold = aws_lb_target_group.this.health_check[0].unhealthy_threshold
    interval            = aws_lb_target_group.this.health_check[0].interval
    timeout             = aws_lb_target_group.this.health_check[0].timeout
  }
}
