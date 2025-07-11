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
  region = "ap-southeast-2"
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

  availability_zones    = ["ap-southeast-2a", "ap-southeast-2b"]
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

###############################
# RDS Module
###############################

module "rds" {
  source = "../../"

  ############################################
  # Core settings
  ############################################
  name                 = local.name
  engine_version       = "15.13"
  instance_class       = "db.t3.medium"
  multi_az             = true
  read_replica_enabled = true

  ############################################
  # Storage & performance
  ############################################
  allocated_storage                     = 20
  max_allocated_storage                 = 200
  storage_type                          = "gp3"
  storage_encrypted                     = true
  kms_key_arn                           = ""
  auto_minor_version_upgrade            = true
  allow_major_version_upgrade           = false
  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  ############################################
  # Networking
  ############################################
  subnet_ids             = module.vpc.database_subnet_ids
  vpc_security_group_ids = [aws_security_group.db.id]
  publicly_accessible    = false

  ############################################
  # Maintenance & monitoring
  ############################################
  backup_retention_period             = 7
  maintenance_window                  = "Sun:06:00-Sun:07:00"
  apply_immediately                   = false
  monitoring_enabled                  = true
  monitoring_interval                 = 60
  create_monitoring_role              = true
  iam_database_authentication_enabled = true

  ############################################
  # Deletion / Snapshot behaviour
  ############################################
  deletion_protection   = false
  skip_final_snapshot   = true
  copy_tags_to_snapshot = true
  force_destroy         = true

  ############################################
  # Tags
  ############################################
  tags = local.tags
}
