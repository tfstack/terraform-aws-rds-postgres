########################
# Locals
########################
locals {
  # KMS key logic
  kms_key_arn = var.storage_encrypted ? (var.kms_key_arn != "" ? var.kms_key_arn : aws_kms_key.this[0].arn) : null

  # Final snapshot logic
  effective_final_snapshot_id = var.skip_final_snapshot ? null : (var.final_snapshot_identifier != "" ? var.final_snapshot_identifier : "${var.name}-final")

  # IAM role logic
  monitoring_role_arn = var.monitoring_enabled ? (var.create_monitoring_role ? aws_iam_role.monitoring[0].arn : var.monitoring_role_arn) : null

  # Parameter group logic
  parameter_group_name = var.create_db_parameter_group ? aws_db_parameter_group.this[0].name : (var.db_parameter_group_name != "" ? var.db_parameter_group_name : null)

  # Password logic - use generated password if create_random_password is true, otherwise use provided password
  master_password = var.create_random_password ? random_password.master[0].result : var.master_password
}

########################
# Random Password
########################
resource "random_password" "master" {
  count            = var.create_random_password ? 1 : 0
  length           = 20
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

########################
# KMS Key (optional)
########################
resource "aws_kms_key" "this" {
  count                   = var.storage_encrypted && var.kms_key_arn == "" ? 1 : 0
  description             = "KMS key for RDS ${var.name}"
  enable_key_rotation     = true
  deletion_window_in_days = 7
  tags                    = merge(var.tags, { Name = "${var.name}-kms" })
}

########################
# IAM Role (Enhanced Monitoring)
########################
data "aws_iam_policy_document" "monitoring_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "monitoring" {
  count              = var.monitoring_enabled && var.create_monitoring_role ? 1 : 0
  name               = "${var.name}-rds-monitoring"
  assume_role_policy = data.aws_iam_policy_document.monitoring_assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "monitoring" {
  count      = var.monitoring_enabled && var.create_monitoring_role ? 1 : 0
  role       = aws_iam_role.monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

########################
# DB Subnet Group
########################
resource "aws_db_subnet_group" "this" {
  name        = "${var.name}-subnets"
  subnet_ids  = var.subnet_ids
  description = "Subnet group for RDS ${var.name}"
  tags        = var.tags
}

########################
# DB Parameter Group (optional)
########################
resource "aws_db_parameter_group" "this" {
  count       = var.create_db_parameter_group ? 1 : 0
  name        = "${var.name}-pg"
  family      = var.parameter_group_family
  description = "Custom parameter group for ${var.name}"

  dynamic "parameter" {
    for_each = var.parameter_group_parameters
    iterator = pg
    content {
      name  = pg.key
      value = pg.value
    }
  }

  tags = var.tags
}

########################
# Primary DB Instance
########################
resource "aws_db_instance" "primary" {
  # Basic Configuration
  identifier     = var.name
  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  # Storage Configuration
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage == 0 ? null : var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = var.storage_encrypted
  kms_key_id            = local.kms_key_arn
  iops                  = var.iops != 0 ? var.iops : null

  # Network Configuration
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = var.vpc_security_group_ids
  multi_az               = var.multi_az
  publicly_accessible    = var.publicly_accessible

  # Authentication
  username = var.snapshot_identifier == "" ? var.master_username : null
  password = var.snapshot_identifier == "" ? local.master_password : null

  # Parameter Group
  parameter_group_name = local.parameter_group_name

  # Backup Configuration
  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  copy_tags_to_snapshot   = var.copy_tags_to_snapshot

  # Maintenance Configuration
  maintenance_window          = var.maintenance_window
  apply_immediately           = var.apply_immediately
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  allow_major_version_upgrade = var.allow_major_version_upgrade

  # Monitoring Configuration
  monitoring_interval = var.monitoring_enabled ? var.monitoring_interval : 0
  monitoring_role_arn = local.monitoring_role_arn

  # Performance Insights
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null

  # Security Configuration
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  deletion_protection                 = var.deletion_protection

  # Snapshot Configuration
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = local.effective_final_snapshot_id
  delete_automated_backups  = var.force_destroy
  snapshot_identifier       = var.snapshot_identifier != "" ? var.snapshot_identifier : null

  tags = merge(var.tags, { Name = var.name })

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      storage_encrypted,
      max_allocated_storage,
      performance_insights_retention_period,
      iops,
      storage_throughput,
    ]
  }
}

########################
# Read Replica (optional)
########################
resource "aws_db_instance" "replica" {
  count               = var.read_replica_enabled ? 1 : 0
  identifier          = "${var.name}-replica"
  replicate_source_db = aws_db_instance.primary.arn

  # Instance Configuration
  instance_class      = var.instance_class
  publicly_accessible = var.publicly_accessible

  # Storage Configuration
  storage_type = var.storage_type
  iops         = var.iops != 0 ? var.iops : null

  # Network Configuration
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = var.vpc_security_group_ids

  # Monitoring Configuration
  monitoring_interval = var.monitoring_enabled ? var.monitoring_interval : 0
  monitoring_role_arn = local.monitoring_role_arn

  # Snapshot Configuration
  skip_final_snapshot = true

  tags = merge(var.tags, { Name = "${var.name}-replica" })

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      storage_encrypted,
      max_allocated_storage,
      enabled_cloudwatch_logs_exports,
      iam_database_authentication_enabled,
      storage_throughput,
      performance_insights_retention_period,
      deletion_protection,
      ca_cert_identifier,
    ]
  }
}
