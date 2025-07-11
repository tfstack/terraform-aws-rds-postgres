terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "random_password" "postgres" {
  length  = 16
  lower   = true
  numeric = true
  special = false
  upper   = true
}

locals {
  name        = "test-postgresdb-${random_string.suffix.result}"
  environment = "dev"
  tags = {
    Environment = local.environment
    ManagedBy   = "terraform"
  }
}

module "vpc" {
  source = "cloudbuildlab/vpc/aws"

  vpc_name = local.name
  vpc_cidr = "10.1.0.0/16"

  availability_zones    = ["ap-southeast-1a", "ap-southeast-1b"]
  private_subnet_cidrs  = ["10.1.2.0/24", "10.1.3.0/24"]
  public_subnet_cidrs   = ["10.1.0.0/24", "10.1.1.0/24"]
  database_subnet_cidrs = ["10.1.4.0/24", "10.1.5.0/24"]

  enable_nat_gateway = true
  create_igw         = true

  tags = local.tags
}

resource "aws_security_group" "db" {
  name        = "${local.name}-db"
  description = "Database traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "PostgreSQL"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { Name = "${local.name}-db-sg" })
}

output "name" {
  value = local.name
}

output "postgres_password" {
  value     = random_password.postgres.result
  sensitive = true
}

output "database_subnet_ids" {
  value = module.vpc.database_subnet_ids
}

output "security_group_ids" {
  value = [aws_security_group.db.id]
}
