# Complete RDS Example

This example demonstrates a full-featured deployment of a PostgreSQL RDS instance using the module, including networking, security, and best practices.

## Features

- Creates a dedicated VPC with public, private, and database subnets
- Deploys a security group for database access
- Provisions a Multi-AZ RDS instance with a read replica
- Enables encryption, monitoring, and performance insights
- Configures backup, maintenance, and deletion protection
- Uses tags for resource management

## Usage

```hcl
provider "aws" {
  region = "ap-southeast-2"
}

module "vpc" {
  source = "cloudbuildlab/vpc/aws"
  vpc_name = "test"
  vpc_cidr = "10.1.0.0/16"
  availability_zones    = ["ap-southeast-2a", "ap-southeast-2b"]
  private_subnet_cidrs  = ["10.1.2.0/24", "10.1.3.0/24"]
  public_subnet_cidrs   = ["10.1.0.0/24", "10.1.1.0/24"]
  database_subnet_cidrs = ["10.1.4.0/24", "10.1.5.0/24"]
  enable_nat_gateway = true
  create_igw         = true
  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

module "rds" {
  source = "../../"
  name   = "test"
  engine_version = "15.13"
  instance_class = "db.t3.medium"
  multi_az       = true
  read_replica_enabled = true
  allocated_storage = 20
  max_allocated_storage = 200
  storage_type = "gp3"
  storage_encrypted = true
  auto_minor_version_upgrade = true
  allow_major_version_upgrade = false
  performance_insights_enabled = true
  performance_insights_retention_period = 7
  subnet_ids = module.vpc.database_subnet_ids
  vpc_security_group_ids = [aws_security_group.db.id]
  publicly_accessible = false
  backup_retention_period = 7
  maintenance_window = "Sun:06:00-Sun:07:00"
  apply_immediately = false
  monitoring_enabled = true
  monitoring_interval = 60
  create_monitoring_role = true
  iam_database_authentication_enabled = true
  deletion_protection = false
  skip_final_snapshot = true
  copy_tags_to_snapshot = true
  force_destroy = true
  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
```

## Requirements

- AWS provider
- Permissions to create VPCs, subnets, security groups, and RDS resources

## Notes

- This example is suitable for production-like environments and demonstrates best practices for RDS deployments.
- Adjust parameters as needed for your use case.
