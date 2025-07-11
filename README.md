# terraform-aws-rds-postgres

Terraform module to deploy and manage AWS RDS PostgreSQL instances

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.2.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_db_instance.primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_instance.replica](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_parameter_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group) | resource |
| [aws_db_subnet_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_iam_role.monitoring](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.monitoring](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [random_password.master](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_iam_policy_document.monitoring_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allocated_storage"></a> [allocated\_storage](#input\_allocated\_storage) | The amount of storage (in GB) to allocate for the DB instance. | `number` | `20` | no |
| <a name="input_allow_major_version_upgrade"></a> [allow\_major\_version\_upgrade](#input\_allow\_major\_version\_upgrade) | Whether major version upgrades are allowed when modifying the instance. | `bool` | `false` | no |
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | Whether changes should be applied immediately or during the next maintenance window. | `bool` | `false` | no |
| <a name="input_auto_minor_version_upgrade"></a> [auto\_minor\_version\_upgrade](#input\_auto\_minor\_version\_upgrade) | Allow automatic minor version upgrades. | `bool` | `true` | no |
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period) | Days to retain automated backups. 0 disables backups. | `number` | `7` | no |
| <a name="input_backup_window"></a> [backup\_window](#input\_backup\_window) | Preferred backup window in HH:MM-HH:MM format (UTC). | `string` | `"03:00-05:00"` | no |
| <a name="input_copy_tags_to_snapshot"></a> [copy\_tags\_to\_snapshot](#input\_copy\_tags\_to\_snapshot) | Copy all DB instance tags to snapshots. | `bool` | `true` | no |
| <a name="input_create_db_parameter_group"></a> [create\_db\_parameter\_group](#input\_create\_db\_parameter\_group) | Whether to create a custom DB parameter group using parameter\_group\_parameters. | `bool` | `false` | no |
| <a name="input_create_monitoring_role"></a> [create\_monitoring\_role](#input\_create\_monitoring\_role) | Whether to create an IAM role for Enhanced Monitoring if monitoring\_enabled is true. | `bool` | `true` | no |
| <a name="input_create_random_password"></a> [create\_random\_password](#input\_create\_random\_password) | Generate a random master password. When true, the master\_password variable is ignored. | `bool` | `true` | no |
| <a name="input_db_parameter_group_name"></a> [db\_parameter\_group\_name](#input\_db\_parameter\_group\_name) | Name of an existing DB parameter group to use. Ignored if create\_db\_parameter\_group is true. | `string` | `""` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Enable deletion protection on the instance. | `bool` | `true` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | PostgreSQL engine version to use. | `string` | `"15.13"` | no |
| <a name="input_final_snapshot_identifier"></a> [final\_snapshot\_identifier](#input\_final\_snapshot\_identifier) | Identifier for the final snapshot. Ignored if skip\_final\_snapshot is true. | `string` | `""` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Set to true to forcefully destroy associated resources such as parameter groups or automated backups when the module is destroyed. Use with caution. | `bool` | `false` | no |
| <a name="input_iam_database_authentication_enabled"></a> [iam\_database\_authentication\_enabled](#input\_iam\_database\_authentication\_enabled) | Enable IAM database authentication. | `bool` | `false` | no |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | The instance class to use (e.g. db.t3.medium). | `string` | `"db.t3.medium"` | no |
| <a name="input_iops"></a> [iops](#input\_iops) | The amount of provisioned IOPS to allocate for the DB instance when using io1, io2 or gp3 storage types. | `number` | `0` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | ARN of an existing KMS key to use. Leave empty to create a new one if encryption is enabled. | `string` | `""` | no |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | Preferred maintenance window in ddd:HH:MM-ddd:HH:MM format (UTC). | `string` | `"Sun:06:00-Sun:07:00"` | no |
| <a name="input_master_password"></a> [master\_password](#input\_master\_password) | Master database password. If create\_random\_password is true, this value will be ignored and a random password will be generated instead. | `string` | `""` | no |
| <a name="input_master_username"></a> [master\_username](#input\_master\_username) | Master database username. Required unless snapshot\_identifier provided. | `string` | `"postgres"` | no |
| <a name="input_max_allocated_storage"></a> [max\_allocated\_storage](#input\_max\_allocated\_storage) | The upper limit (in GB) to which Amazon RDS can automatically scale storage. Set to 0 to disable autoscaling. | `number` | `0` | no |
| <a name="input_monitoring_enabled"></a> [monitoring\_enabled](#input\_monitoring\_enabled) | Enable Enhanced Monitoring. | `bool` | `false` | no |
| <a name="input_monitoring_interval"></a> [monitoring\_interval](#input\_monitoring\_interval) | Enhanced Monitoring interval in seconds (e.g. 60 \| 30 \| 15). | `number` | `60` | no |
| <a name="input_monitoring_role_arn"></a> [monitoring\_role\_arn](#input\_monitoring\_role\_arn) | ARN of an existing IAM role to use for Enhanced Monitoring. Used when create\_monitoring\_role is false. | `string` | `""` | no |
| <a name="input_multi_az"></a> [multi\_az](#input\_multi\_az) | Whether to deploy the instance in multiple AZs. | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Base name used for resource identifiers. | `string` | n/a | yes |
| <a name="input_parameter_group_family"></a> [parameter\_group\_family](#input\_parameter\_group\_family) | Parameter group family to use when creating a custom group (e.g., postgres15). | `string` | `"postgres15"` | no |
| <a name="input_parameter_group_parameters"></a> [parameter\_group\_parameters](#input\_parameter\_group\_parameters) | A map of parameter names to values for the custom parameter group. | `map(string)` | `{}` | no |
| <a name="input_performance_insights_enabled"></a> [performance\_insights\_enabled](#input\_performance\_insights\_enabled) | Enable Performance Insights. | `bool` | `true` | no |
| <a name="input_performance_insights_retention_period"></a> [performance\_insights\_retention\_period](#input\_performance\_insights\_retention\_period) | Retention period (in days) for Performance Insights metrics (7, 731, or 2190). | `number` | `7` | no |
| <a name="input_publicly_accessible"></a> [publicly\_accessible](#input\_publicly\_accessible) | Whether the DB instance is publicly accessible. | `bool` | `false` | no |
| <a name="input_read_replica_enabled"></a> [read\_replica\_enabled](#input\_read\_replica\_enabled) | Create a single read replica of the primary instance. | `bool` | `false` | no |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | Skip taking a final snapshot before deletion. | `bool` | `false` | no |
| <a name="input_snapshot_identifier"></a> [snapshot\_identifier](#input\_snapshot\_identifier) | DB snapshot identifier to restore from. Leave empty for fresh instance. | `string` | `""` | no |
| <a name="input_storage_encrypted"></a> [storage\_encrypted](#input\_storage\_encrypted) | Whether to enable storage encryption. | `bool` | `true` | no |
| <a name="input_storage_type"></a> [storage\_type](#input\_storage\_type) | One of standard \| gp2 \| gp3 \| io1 \| io2 | `string` | `"gp3"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs for the DB subnet group. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to apply to all resources that support it. | `map(string)` | `{}` | no |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | List of security group IDs to associate. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | ARN of the primary RDS instance |
| <a name="output_db_subnet_group_arn"></a> [db\_subnet\_group\_arn](#output\_db\_subnet\_group\_arn) | ARN of the DB subnet group |
| <a name="output_db_subnet_group_name"></a> [db\_subnet\_group\_name](#output\_db\_subnet\_group\_name) | Name of the DB subnet group in use |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | Connection endpoint |
| <a name="output_engine"></a> [engine](#output\_engine) | Database engine |
| <a name="output_engine_version"></a> [engine\_version](#output\_engine\_version) | Database engine version |
| <a name="output_id"></a> [id](#output\_id) | ID of the primary RDS instance |
| <a name="output_identifier"></a> [identifier](#output\_identifier) | Identifier of the primary RDS instance |
| <a name="output_kms_key_id"></a> [kms\_key\_id](#output\_kms\_key\_id) | KMS key ID used for encryption (if enabled) |
| <a name="output_monitoring_role_arn"></a> [monitoring\_role\_arn](#output\_monitoring\_role\_arn) | ARN of the monitoring role (if created) |
| <a name="output_parameter_group_name"></a> [parameter\_group\_name](#output\_parameter\_group\_name) | Name of the DB parameter group in use |
| <a name="output_password"></a> [password](#output\_password) | Master password for the database (if generated) |
| <a name="output_port"></a> [port](#output\_port) | Database port |
| <a name="output_replica_arn"></a> [replica\_arn](#output\_replica\_arn) | ARN of the read replica (if enabled) |
| <a name="output_replica_endpoint"></a> [replica\_endpoint](#output\_replica\_endpoint) | Connection endpoint for the read replica (if enabled) |
| <a name="output_replica_id"></a> [replica\_id](#output\_replica\_id) | ID of the read replica (if enabled) |
| <a name="output_replica_identifier"></a> [replica\_identifier](#output\_replica\_identifier) | Identifier of the read replica (if enabled) |
| <a name="output_replica_status"></a> [replica\_status](#output\_replica\_status) | Status of the read replica (if enabled) |
| <a name="output_status"></a> [status](#output\_status) | Status of the primary RDS instance |
| <a name="output_username"></a> [username](#output\_username) | Master username for the database |
<!-- END_TF_DOCS -->
