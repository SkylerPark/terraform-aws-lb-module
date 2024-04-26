module "nlb" {
  source          = "../../modules/nlb"
  name            = "parksm-nlb-alb"
  is_public       = true
  ip_address_type = "ipv4"
  vpc_id          = module.vpc.id

  network_mapping = [
    for subnet in module.public_subnet_group.ids : {
      subnet = subnet
    }
  ]

  default_security_group = {
    enabled = true
    name    = "parksm-nlb-alb"
    ingress_rules = [
      {
        id          = "tcp/80"
        description = "Allow HTTP from VPC"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        ipv4_cidrs  = ["0.0.0.0/0"]
      },
      {
        id          = "tcp/443"
        description = "Allow HTTPS from VPC"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        ipv4_cidrs  = ["0.0.0.0/0"]
      }
    ]
    egress_rules = [
      {
        id          = "all/all"
        description = "Allow all traffics to the internet"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        ipv4_cidrs  = ["0.0.0.0/0"]
      },
    ]
  }

  ## Attributes
  route53_resolver_availability_zone_affinity = "ANY"
  cross_zone_load_balancing_enabled           = true
  deletion_protection_enabled                 = false

  listeners = [
    {
      port         = 80
      protocol     = "TCP"
      target_group = module.parksm_alb_tg_http.arn
    },
    {
      port         = 443
      protocol     = "TCP" # Note: TLS 로 설정시 tls.certificate 인증서 발급 후 설정 현재는 임시로 설정
      target_group = module.parksm_alb_tg_https.arn
      tls = {
        certificate = "arn:aws:acm:Region:444455556666:certificate/certificate_ID"
      }
    }
  ]
}

module "parksm_alb_tg_http" {
  source      = "../../modules/nlb-target-group"
  name        = "parksm-alb-tg"
  target_type = "alb"
  port        = 80
  protocol    = "TCP"
  vpc_id      = module.vpc.id

  health_check = {
    protocol = "HTTP"
    port     = 80
    path     = "/health"

    interval            = 10
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  stickiness_enabled = false
  targets = {
    parksm-alb = {
      target_id = module.alb.arn
    }
  }
}

module "parksm_alb_tg_https" {
  source      = "../../modules/nlb-target-group"
  name        = "parksm-alb-tg"
  target_type = "alb"
  port        = 443
  protocol    = "TCP"
  vpc_id      = module.vpc.id

  health_check = {
    protocol = "HTTP"
    port     = 443
    path     = "/health"

    interval            = 10
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  stickiness_enabled = false
  targets = {
    parksm-alb = {
      target_id = module.alb.arn
    }
  }
}
