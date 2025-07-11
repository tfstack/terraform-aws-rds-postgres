# Basic RDS Example

This example demonstrates the minimal configuration required to deploy a PostgreSQL RDS instance using the module.

## Features

- Uses the default VPC and subnets
- Creates a security group allowing PostgreSQL access from anywhere (0.0.0.0/0)
- Deploys a single RDS instance (no replica, no Multi-AZ)
- Uses hardcoded credentials (for demo/testing only)
- Publicly accessible (for demonstration; not recommended for production)

## Usage

```hcl
provider "aws" {
  region = "ap-southeast-2"
}

module "rds" {
  source = "../../"
  name   = "basic-db"
  instance_class = "db.t3.micro"
  master_username = "postgres"
  master_password = "Password123!"
  create_random_password = false
  subnet_ids = data.aws_subnet_ids.default.ids
  vpc_security_group_ids = [aws_security_group.db.id]
  publicly_accessible = true
  read_replica_enabled = false
  skip_final_snapshot = true
  deletion_protection = false
  copy_tags_to_snapshot = false
  force_destroy = true
  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
```

## Requirements

- AWS provider
- Default VPC and subnets in the target region

## Notes

- Do **not** use this configuration in production. It is for demonstration and testing only.
- The RDS instance will be publicly accessible and use a weak, hardcoded password.
