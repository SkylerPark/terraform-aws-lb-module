locals {
  region = "ap-northeast-2"
}

module "alb" {
  source          = "../../modules/alb"
  name            = "parksm-alb-instance"
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
    name    = "parksm-alb-instance"
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
  desync_mitigation_mode      = "defensive"
  drop_invalid_header_fields  = false
  deletion_protection_enabled = false
  http2_enabled               = false
  waf_fail_open_enabled       = false
  idle_timeout                = 60

  listeners = [
    {
      port                = 80
      protocol            = "HTTP"
      default_action_type = "REDIRECT_301"
      default_action_parameters = {
        protocol = "HTTPS"
        port     = 443
      }
    },
    {
      port                = 443
      protocol            = "HTTP" # Note: HTTPS 로 설정시 tls.certificate 인증서 발급 후 설정 현재는 임시로 설정
      default_action_type = "FORWARD"
      tls = {
        certificate = "arn:aws:acm:Region:444455556666:certificate/certificate_ID"
      }
      default_action_parameters = {
        target_group = module.target_group_v1.arn
      }
    }
  ]
}

module "target_group_v1" {
  source           = "../../modules/alb-target-group"
  name             = "parksm-tg"
  target_type      = "instance"
  port             = 8080
  protocol         = "HTTP"
  protocol_version = "HTTP1"
  vpc_id           = module.vpc.id

  health_check = {
    protocol = "HTTP"
    port     = 80
    path     = "/health"

    interval            = 10
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  stickiness = {
    enabled = false
  }
  load_balancing_algorithm_type = "least_outstanding_requests"
  targets = {
    for instance, value in local.instances : "parksm-rnd-test-${instance}" => {
      target_id = module.instance[instance].id
    } if value.is_lb
  }
}
