###################################################
# Listener
###################################################
resource "aws_lb_listener" "this" {
  for_each          = { for listener in var.listeners : listener.port => listener }
  load_balancer_arn = aws_lb.this.arn
  port              = each.key
  protocol          = each.value.protocol

  certificate_arn = each.value.protocol == "TLS" ? var.tls.certificate : null
  ssl_policy      = each.value.protocol == "TLS" ? var.tls.security_policy : null
  alpn_policy     = each.value.protocol == "TLS" ? var.tls.alpn_policy : null

  ## forward
  default_action {
    type             = "forward"
    target_group_arn = each.value.target_group
  }

  tags = merge(
    {
      "Name" = "${aws_lb.this.name}-${each.value.protocol}:${each.key}"
    },
    var.tags
  )
}

###################################################
# Certificates for Listeners
###################################################
locals {
  certificates = flatten([
    for listener in var.listeners : [
      for certificate in try(listener.tls.additional_certificates, []) : {
        name            = "${aws_lb.this.name}-${listener.protocol}:${listener.port}/${certificate}"
        listener_arn    = aws_lb_listener.this[listener.port].arn
        certificate_arn = certificate
      } if listener.protocol == "TLS"
    ]
  ])
}
resource "aws_lb_listener_certificate" "this" {
  for_each = { for certificate in local.certificates : certificate.name => certificate }

  listener_arn    = each.value.listener_arn
  certificate_arn = each.value.certificate_arn
}
