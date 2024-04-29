locals {
  region = "ap-northeast-2"
}

module "nlb_security_group" {
  source                 = "git::https://github.com/SkylerPark/terraform-aws-vpc-module.git//modules/security-group/?ref=tags/1.1.0"
  name                   = "parksm-nlb-test"
  vpc_id                 = module.vpc.id
  revoke_rules_on_delete = true

  ingress_rules = [
    {
      id          = "tcp/80"
      description = "Allow HTTP from Any"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      ipv4_cidrs  = ["0.0.0.0/0"]
    },
    {
      id          = "tcp/443"
      description = "Allow HTTPS from Any"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      ipv4_cidrs  = ["0.0.0.0/0"]
    }
  ]
  egress_rules = [
    {
      id          = "all/all"
      description = "Allow all traffic form Any"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      ipv4_cidrs  = ["0.0.0.0/0"]
    },
  ]
}

module "nlb" {
  source          = "../../modules/nlb"
  name            = "parksm-nlb-instance"
  is_public       = true
  ip_address_type = "ipv4"
  vpc_id          = module.vpc.id
  security_groups = [module.nlb_security_group.id]

  network_mapping = [
    for subnet in module.public_subnet_group.ids : {
      subnet = subnet
    }
  ]

  ## Attributes
  route53_resolver_availability_zone_affinity = "ANY"
  cross_zone_load_balancing_enabled           = true
  deletion_protection_enabled                 = false

  listeners = [
    {
      port         = 80
      protocol     = "TCP"
      target_group = module.target_group_v1.arn
    },
    {
      port         = 443
      protocol     = "TCP" # Note: TLS 로 설정시 tls.certificate 인증서 발급 후 설정 현재는 임시로 설정
      target_group = module.target_group_v1.arn
      tls = {
        certificate = "arn:aws:acm:Region:444455556666:certificate/certificate_ID"
      }
    }
  ]
}

module "target_group_v1" {
  source      = "../../modules/nlb-target-group"
  name        = "parksm-tg"
  target_type = "instance"
  port        = 8080
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
    for instance, value in local.instances : "parksm-rnd-test-${instance}" => {
      target_id = module.instance[instance].id
    } if value.is_lb
  }
}
