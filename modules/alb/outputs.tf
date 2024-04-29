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
  description = "load balancer listener 리스트"
  value       = module.listener
}
