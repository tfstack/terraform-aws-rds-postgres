####################################
# Primary Instance Outputs
####################################

output "arn" {
  description = "ARN of the primary RDS instance"
  value       = aws_db_instance.primary.arn
}

output "id" {
  description = "ID of the primary RDS instance"
  value       = aws_db_instance.primary.id
}

output "identifier" {
  description = "Identifier of the primary RDS instance"
  value       = aws_db_instance.primary.identifier
}

output "endpoint" {
  description = "Connection endpoint"
  value       = aws_db_instance.primary.endpoint
}

output "port" {
  description = "Database port"
  value       = aws_db_instance.primary.port
}

output "engine" {
  description = "Database engine"
  value       = aws_db_instance.primary.engine
}

output "engine_version" {
  description = "Database engine version"
  value       = aws_db_instance.primary.engine_version
}

output "status" {
  description = "Status of the primary RDS instance"
  value       = aws_db_instance.primary.status
}

####################################
# Authentication Outputs
####################################

output "username" {
  description = "Master username for the database"
  value       = var.master_username
}

output "password" {
  description = "Master password for the database (if generated)"
  value       = var.create_random_password && var.master_password == "" ? random_password.master[0].result : null
  sensitive   = true
}

####################################
# Read Replica Outputs
####################################

output "replica_arn" {
  description = "ARN of the read replica (if enabled)"
  value       = var.read_replica_enabled ? aws_db_instance.replica[0].arn : null
}

output "replica_id" {
  description = "ID of the read replica (if enabled)"
  value       = var.read_replica_enabled ? aws_db_instance.replica[0].id : null
}

output "replica_identifier" {
  description = "Identifier of the read replica (if enabled)"
  value       = var.read_replica_enabled ? aws_db_instance.replica[0].identifier : null
}

output "replica_endpoint" {
  description = "Connection endpoint for the read replica (if enabled)"
  value       = var.read_replica_enabled ? aws_db_instance.replica[0].endpoint : null
}

output "replica_status" {
  description = "Status of the read replica (if enabled)"
  value       = var.read_replica_enabled ? aws_db_instance.replica[0].status : null
}

####################################
# Infrastructure Outputs
####################################

output "db_subnet_group_name" {
  description = "Name of the DB subnet group in use"
  value       = aws_db_subnet_group.this.name
}

output "db_subnet_group_arn" {
  description = "ARN of the DB subnet group"
  value       = aws_db_subnet_group.this.arn
}

output "parameter_group_name" {
  description = "Name of the DB parameter group in use"
  value       = local.parameter_group_name
}

output "kms_key_id" {
  description = "KMS key ID used for encryption (if enabled)"
  value       = local.kms_key_arn
}

output "monitoring_role_arn" {
  description = "ARN of the monitoring role (if created)"
  value       = local.monitoring_role_arn
}
