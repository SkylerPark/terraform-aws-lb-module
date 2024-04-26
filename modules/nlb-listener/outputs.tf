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

output "default_actions" {
  description = "listener default action 정보"
  value = {
    type = "FORWARD"
    forward = {
      arn  = var.target_group
      name = split("/", var.target_group)[1]
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
    alpn_policy     = aws_lb_listener.this.alpn_policy
  } : null
}
