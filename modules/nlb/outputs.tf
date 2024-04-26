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

output "listeners" {
  description = "load balancer listener 정보 리스트"
  value       = module.listener
}
