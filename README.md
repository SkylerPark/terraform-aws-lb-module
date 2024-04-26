# terraform-aws-lb-module

[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white&style=flat-square)](https://github.com/pre-commit/pre-commit)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Component

아래 도구를 이용하여 모듈작성을 하였습니다. 링크를 참고하여 OS 에 맞게 설치 합니다.

> **macos** : ./bin/install-macos.sh

- [pre-commit](https://pre-commit.com)
- [terraform](https://terraform.io)
- [tfenv](https://github.com/tfutils/tfenv)
- [terraform-docs](https://github.com/segmentio/terraform-docs)
- [tfsec](https://github.com/tfsec/tfsec)
- [tflint](https://github.com/terraform-linters/tflint)

## Services

Terraform 모듈을 사용하여 아래 서비스를 관리 합니다.

- **AWS LB (Load Balancer)**
  - nlb
  - nlb-target-group
  - nlb-listener
  - alb
  - alb-target-group
  - alb-listener

## Usage

아래 예시를 활용하여 작성가능하며 examples 코드를 참고 부탁드립니다.

### alb

alb 를 만들고 instance target group 으로 세팅 하는 예시 입니다.

```hcl
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
```

### nlb

nlb 를 만들고 instance target group 으로 세팅 하는 예시 입니다.

```hcl
module "nlb" {
  source          = "../../modules/nlb"
  name            = "parksm-nlb-instance"
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
    name    = "parksm-nlb-instance"
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
```

### nlb with alb

nlb 를 만들어 alb 를 타겟으로 세팅 하는 예시 입니다.

```hcl
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
```
