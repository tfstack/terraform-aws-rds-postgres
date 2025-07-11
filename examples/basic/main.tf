terraform {
  required_version = ">= 1.0"
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

locals {
  name        = "postgresdb"
  environment = "dev"
  tags = {
    Environment = local.environment
    ManagedBy   = "terraform"
  }
}

###############################
# Networking (default VPC)
###############################

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

  # Tags
  tags = local.tags
}

# Security group for the RDS instance
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

resource "random_password" "postgres" {
  length  = 16
  lower   = true
  numeric = true
  special = false
  upper   = true
}

###############################
# RDS Module
###############################

module "rds" {
  source = "../../"

  # Core settings
  name           = local.name
  instance_class = "db.t3.micro"

  # Credentials (DON'T use static credentials in production)
  master_username        = "postgres"
  master_password        = random_password.postgres.result
  create_random_password = false

  # Networking
  subnet_ids             = module.vpc.database_subnet_ids
  vpc_security_group_ids = [aws_security_group.db.id]
  publicly_accessible    = true

  # Cost-saving and testing settings
  multi_az                = false
  read_replica_enabled    = false
  skip_final_snapshot     = true
  deletion_protection     = false
  copy_tags_to_snapshot   = false
  force_destroy           = true
  backup_retention_period = 0 # Disable backups for cost savings

  tags = local.tags
}
