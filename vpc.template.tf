
data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.network_name}-vpc"
  cidr = var.vpc_CIDR_block

  azs                    = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  private_subnets        = [var.private_subnet_a_CIDR_block, var.private_subnet_b_CIDR_block]
  public_subnets         = [var.public_subnet_a_CIDR_block, var.public_subnet_b_CIDR_block]
  enable_ipv6            = var.enable_ipv6
  enable_nat_gateway     = var.enable_nat_gateway
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az
  enable_dns_hostnames   = var.enable_dns_hostnames
  enable_dns_support     = var.enable_dns_support
  public_subnet_tags     = var.tags

  vpc_tags = var.tags
}


{% if enable_vpc_endpoints is defined and enable_vpc_endpoints %}
resource "aws_security_group" "vpc_sg" {
  name_prefix = "${var.network_name}-sg"
  description = "Security group for VPC"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSL from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  tags = var.tags
}

resource "aws_security_group" "vpc_endpoints_sg" {
  name_prefix = "vpc_endpoints_sg"
  description = "Security group for VPC endpoints"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSL to VPC endpoint"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  egress {
    description = "SSL from VPC endpoint"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

module "vpc_endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  vpc_id             = module.vpc.vpc_id
  security_group_ids = [aws_security_group.vpc_endpoints_sg.id]

  endpoints = {
    s3 = {
      # gateway endpoint required for private ecr
      service             = "s3"
      tags                = { Name = "s3-vpc-endpoint" }
      subnet_ids          = module.vpc.private_subnets
      service_type        = "Gateway"
      route_table_ids     = module.vpc.private_route_table_ids
    },
    logs = {
      service             = "logs"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
    },
    ecs = {
      service             = "ecs"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
    },
    ecs_telemetry = {
      create              = false
      service             = "ecs-telemetry"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
    },
    ecr_api = {
      service             = "ecr.api"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
    },
    ecr_dkr = {
      service             = "ecr.dkr"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
    },
    ssm = {
      service             = "ssm"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      security_group_ids  = [aws_security_group.vpc_sg.id]
    },
    ssmmessages = {
      service             = "ssmmessages"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
    },
    ec2 = {
      service             = "ec2"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      security_group_ids  = [aws_security_group.vpc_sg.id]
    },
    ec2messages = {
      service             = "ec2messages"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
    },

  }

  tags = var.tags
}

data "aws_iam_policy_document" "generic_endpoint_policy" {
  statement {
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

{% endif %}

locals {
  vpc_id = module.vpc.vpc_id
}

# output the vpc ids
output "vpc_id" {
  value = local.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}

output "default_security_group_id" {
  value = module.vpc.default_security_group_id
}