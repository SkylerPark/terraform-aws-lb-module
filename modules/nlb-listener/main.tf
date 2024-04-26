locals {
  load_balancer_name = split("/", var.load_balancer)[2]
}

###################################################
# Listener
###################################################
resource "aws_lb_listener" "this" {
  load_balancer_arn = var.load_balancer

  port     = var.port
  protocol = var.protocol

  certificate_arn = var.protocol == "TLS" ? var.tls.certificate : null
  ssl_policy      = var.protocol == "TLS" ? var.tls.security_policy : null
  alpn_policy     = var.protocol == "TLS" ? var.tls.alpn_policy : null

  ## forward
  default_action {
    type             = "forward"
    target_group_arn = var.target_group
  }

  tags = merge(
    {
      "Name" = "${local.load_balancer_name}-${var.port}"
    },
    var.tags,
  )
}

###################################################
# Additional Certificates for Listener
###################################################
resource "aws_lb_listener_certificate" "this" {
  for_each = toset(var.protocol == "TLS" ? var.tls.additional_certificates : [])

  listener_arn    = aws_lb_listener.this.arn
  certificate_arn = each.key
}
