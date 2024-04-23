## instance
module "ssh_key" {
  source             = "git::https://github.com/SkylerPark/terraform-aws-ec2-module.git//modules/key-pair/?ref=tags/1.1.2"
  name               = "parksm-test"
  create_private_key = true
}

locals {
  instances = {
    "01" = {
      is_lb = true
    }
    "02" = {
      is_lb = false
    }
  }
}

module "security_group" {
  source                 = "git::https://github.com/SkylerPark/terraform-aws-vpc-module.git//modules/security-group/?ref=tags/1.1.0"
  name                   = "parksm-test"
  vpc_id                 = module.vpc.id
  revoke_rules_on_delete = true

  ingress_rules = [
    {
      id          = "tcp/80"
      description = "Allow HTTP from VPC"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      ipv4_cidrs  = [module.vpc.ipv4_cidrs]
    },
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

module "instance" {
  source            = "git::https://github.com/SkylerPark/terraform-aws-ec2-module.git//modules/instance/?ref=tags/1.1.2"
  for_each          = local.instances
  name              = "parksm-rnd-test-${each.key}"
  instance_type     = "t2.micro"
  key_name          = module.ssh_key.name
  ami               = data.aws_ami.amazon_linux2.id
  availability_zone = local.availability_zones[(index(keys(local.instances), each.key)) % length(local.availability_zones)]
  subnet_id         = module.public_subnet_group.ids[(index(keys(local.instances), each.key)) % length(module.public_subnet_group.ids)]
  security_groups   = [module.security_group.id]

  root_block_device = [
    {
      delete_on_termination = true
      encrypted             = true
      volume_size           = 50
      volume_type           = "gp3"
    }
  ]

  metadata_options = {
    http_endpoint_enabled = true
    http_tokens_enabled   = true
    instance_tags_enabled = true
  }

  ebs_block_device = {
    swap = {
      device_name = "/dev/sdb"
      encrypted   = true
      volume_size = 10
      volume_type = "gp3"
    }
  }
}
